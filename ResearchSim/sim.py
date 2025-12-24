"""
Convenience Store Simulation with Automation Scenarios (SimPy Version)
Author: Ziyan Hirani

Scenarios:
    A0 - Baseline (manual checkouts, manual inventory)
    A1 - Self-checkout
    A2 - Theft AI only
    A3 - Self-checkout + Theft AI
    A4 - Full Automation (Self-checkout + Theft AI + Inventory AI)
    A5 - Inventory AI only (no self-checkout, no theft AI)

Simulates:
- Customer arrivals (Poisson process)
- Shopping and checkout
- Weekly manual inventory events (A0–A3 only)
- Theft attempts and detection
- Labor, AI, kiosk, and inventory costs
- Camera-based shrink reduction when Theft AI is active (A2/A3/A4)
- Shrink, revenue, profit, satisfaction over 1 simulated year
"""

import simpy
import random
import numpy as np

# -----------------------------
# 1. SIMULATION PARAMETERS
# -----------------------------
SIM_TIME = 12 * 60 * 365   # 12 hours/day × 365 days, in minutes
WEEK_MINUTES = 7 * 24 * 60

STORES = {
    "Small":  {"cashiers": 1, "kiosks": 1, "arrival_interval": 2.0},
    "Medium": {"cashiers": 3, "kiosks": 2, "arrival_interval": 1.2},
    "Large":  {"cashiers": 5, "kiosks": 3, "arrival_interval": 0.75}
}

# Customer behavior
MIN_SHOP_TIME = 3
MAX_SHOP_TIME = 10
MIN_BASKET_ITEMS = 1
MAX_BASKET_ITEMS = 15

# Financial constants
AVG_ITEM_PRICE = 7.80 / 4         # ~1.95 per item
PROFIT_MARGIN = 0.25

WAGE_PER_HOUR = 15.0
WAGE_PER_MIN = WAGE_PER_HOUR / 60

# --- Theft AI camera cost (per camera) ---
# Approx: $40/month per camera ˜ $480/year ˜ $0.055/hour
AI_COST_PER_HOUR_PER_CAMERA = 0.055
AI_COST_PER_MIN_PER_CAMERA = AI_COST_PER_HOUR_PER_CAMERA / 60

# Kiosk cost (per kiosk)
KIOSK_COST_PER_HOUR = 1.50
KIOSK_COST_PER_MIN = KIOSK_COST_PER_HOUR / 60

# Shrink parameters (baseline shrink rate before AI)
SHRINK_RATE = 0.016               # 1.6% of sales

# Inventory AI
INVENTORY_AI_COST_PER_HOUR = 0.13
INVENTORY_AI_COST_PER_MIN = INVENTORY_AI_COST_PER_HOUR / 60
INVENTORY_AI_SHRINK_REDUCTION = 0.10   # extra 10% shrink reduction (multiplicative)

# Manual inventory hours per week (used for cost AND weekly events)
INVENTORY_HOURS_PER_WEEK = {
    "Small":  1,   # 1 hour/week
    "Medium": 2,   # 2 hours/week
    "Large":  2    # 2 hours/week
}

# Number of workers pulled off checkout for inventory
INVENTORY_WORKERS = {
    "Small": 1,
    "Medium": 1,
    "Large": 2
}

# Theft probabilities
THEFT_PROBABILITY = 0.05
CASHIER_CATCH_PROB = 0.10
AI_THEFT_CATCH_PROB = 0.60

# Camera-based shrink model:
# number of AI-enabled cameras when Theft AI is active (A2/A3/A4)
CAMERAS_PER_STORE = {
    "Small": 2,
    "Medium": 3,
    "Large": 5
}

# Per-camera shrink reduction (diminishing returns)
CAMERA_EFFECT_SEQUENCE = [0.15, 0.10, 0.07, 0.05]  # 1st–4th camera

# To store scenario summaries for final tables
RESULTS = []


# ------------------------------------------------------------
# Helper: compute shrink reduction from cameras
# ------------------------------------------------------------
def camera_shrink_reduction(store_size: str) -> float:
    """
    Computes total shrink reduction from AI cameras for a given store size,
    using diminishing returns per camera. Only used when Theft AI is active.
    """
    n_cams = CAMERAS_PER_STORE.get(store_size, 0)
    total = 0.0
    for i in range(n_cams):
        if i < len(CAMERA_EFFECT_SEQUENCE):
            total += CAMERA_EFFECT_SEQUENCE[i]
        else:
            total += CAMERA_EFFECT_AFTER_4
    # Cap total reduction so it never exceeds 50%
    return min(total, MAX_TOTAL_CAMERA_REDUCTION)


# ------------------------------------------------------------
# Store Class
# ------------------------------------------------------------
class Store:
    def __init__(self, env, store_size, scenario):
        self.env = env
        self.size = store_size        # 'Small', 'Medium', 'Large'
        self.scenario = scenario      # 'A0'...'A5'

        conf = STORES[store_size]

        # ----- STAFFING RULES -----
        if scenario in ("A1", "A3", "A4"):
            # Self-checkout scenarios: fewer cashiers + kiosks
            self.num_cashiers = 1
            self.num_kiosks = conf["kiosks"]
        elif scenario == "A5":
            # Inventory AI only: normal staffing, no kiosks
            self.num_cashiers = conf["cashiers"]
            self.num_kiosks = 0
        else:
            # A0 (baseline) and A2 (theft AI only)
            self.num_cashiers = conf["cashiers"]
            self.num_kiosks = 0

        # Resources
        self.cashiers = simpy.Resource(env, capacity=self.num_cashiers)
        self.kiosks = simpy.Resource(env, capacity=self.num_kiosks) if self.num_kiosks > 0 else None

        # Metrics
        self.wait_times = []
        self.satisfaction_scores = []
        self.total_customers = 0
        self.abandoned_customers = 0

        # Financials
        self.revenue = 0
        self.gross_profit = 0
        self.theft_loss = 0   # diagnostic only

    # ----- Labor & Cost Calculations -----
    def get_arrival_interval(self):
        return STORES[self.size]["arrival_interval"]

    def calc_labor_cost(self):
        # Front-of-house cashier labor (not including manual inventory)
        return self.num_cashiers * WAGE_PER_MIN * SIM_TIME

    def calc_theft_ai_cost(self):
        """
        Theft AI is only active in A2, A3, A4.
        Cost scales with number of cameras in that store size.
        """
        if self.scenario in ("A2", "A3", "A4"):
            num_cameras = CAMERAS_PER_STORE[self.size]
            return num_cameras * AI_COST_PER_MIN_PER_CAMERA * SIM_TIME
        return 0

    def calc_kiosk_cost(self):
        if self.scenario in ("A1", "A3", "A4"):
            return self.num_kiosks * KIOSK_COST_PER_MIN * SIM_TIME
        return 0

    def calc_inventory_ai_cost(self):
        if self.scenario in ("A4", "A5"):
            return INVENTORY_AI_COST_PER_MIN * SIM_TIME
        return 0

    def calc_manual_inventory_cost(self):
        # Only A0–A3 pay manual inventory labor cost
        if self.scenario in ("A0", "A1", "A2", "A3"):
            hours = INVENTORY_HOURS_PER_WEEK[self.size]
            return hours * WAGE_PER_HOUR * 52
        return 0

    def effective_shrink_rate(self):
        """
        Baseline shrink starts at SHRINK_RATE, then is reduced multiplicatively:
        - Theft AI (A2/A3/A4) ? camera-based shrink reduction per store size
        """
        rate = SHRINK_RATE

        # Theft AI shrink improvement (A2, A3, A4) via cameras
        if self.scenario in ("A2", "A3", "A4"):
            cam_reduction = camera_shrink_reduction(self.size)
            rate *= (1.0 - cam_reduction)

        # Inventory AI shrink improvement (A4, A5)
        if self.scenario in ("A4", "A5"):
            rate *= (1.0 - INVENTORY_AI_SHRINK_REDUCTION)

        return rate

    # ----- Compute and Print Results -----
    def summarize_and_print(self):
        """Compute metrics, print them, and return a summary dict for tables."""
        print(f"\n--- RESULTS: {self.size} Store | Scenario {self.scenario} ---")
        print(f"Total customers: {self.total_customers}")
        print(f"Abandoned: {self.abandoned_customers}")

        if self.wait_times:
            avg_wait = float(np.mean(self.wait_times))
            p95_wait = float(np.percentile(self.wait_times, 95))
            print(
                f"Avg wait: {avg_wait:.2f} min | "
                f"95th %: {p95_wait:.2f} min"
            )
        else:
            avg_wait = 0.0
            p95_wait = 0.0
            print("Avg wait: N/A")

        if self.satisfaction_scores:
            avg_satisfaction = float(np.mean(self.satisfaction_scores))
            print(f"Avg satisfaction: {avg_satisfaction:.2f}/10")
        else:
            avg_satisfaction = 0.0
            print("Avg satisfaction: N/A")

        labor_cost = self.calc_labor_cost()
        theft_ai_cost = self.calc_theft_ai_cost()
        kiosk_cost = self.calc_kiosk_cost()
        inventory_ai_cost = self.calc_inventory_ai_cost()
        manual_inventory_cost = self.calc_manual_inventory_cost()

        shrink_loss = self.revenue * self.effective_shrink_rate()

        net_profit = (
            self.gross_profit
            - shrink_loss
            - labor_cost
            - theft_ai_cost
            - kiosk_cost
            - inventory_ai_cost
            - manual_inventory_cost
        )

        print("\n--- Financials ---")
        print(f"Revenue: ${self.revenue:,.2f}")
        print(f"Gross Profit: ${self.gross_profit:,.2f}")
        print(f"Shrink Loss (modeled %): ${shrink_loss:,.2f}")
        print(f"Labor Cost (cashiers): ${labor_cost:,.2f}")
        print(f"Manual Inventory Cost (A0–A3): ${manual_inventory_cost:,.2f}")
        print(f"Theft AI Cost (A2/A3/A4): ${theft_ai_cost:,.2f}")
        print(f"Kiosk Cost (A1/A3/A4): ${kiosk_cost:,.2f}")
        print(f"Inventory AI Cost (A4/A5): ${inventory_ai_cost:,.2f}")
        print(f"NET PROFIT: ${net_profit:,.2f}")

        abandon_rate = (self.abandoned_customers / self.total_customers * 100.0) if self.total_customers > 0 else 0.0

        return {
            "scenario": self.scenario,
            "store": self.size,
            "net_profit": net_profit,
            "avg_satisfaction": avg_satisfaction,
            "abandon_rate": abandon_rate,
            "avg_wait": avg_wait,
            "p95_wait": p95_wait,
            "revenue": self.revenue
        }


# ------------------------------------------------------------
# Weekly Inventory Process (manual only, A0–A3)
# ------------------------------------------------------------
def inventory_process(env, store):
    """
    Once per week, for scenarios A0–A3:
      - Some cashiers are occupied doing manual inventory instead of checkout.
      - Implemented using dummy requests that occupy cashier capacity.
    """
    if store.scenario not in ("A0", "A1", "A2", "A3"):
        return  # no manual inventory disruptions in A4/A5

    while True:
        # Wait one week
        yield env.timeout(WEEK_MINUTES)

        hours = INVENTORY_HOURS_PER_WEEK[store.size]
        duration = hours * 60  # convert hours to minutes
        num_workers = INVENTORY_WORKERS[store.size]

        if num_workers <= 0:
            continue

        # Occupy cashier capacity with dummy requests
        dummy_reqs = []
        for _ in range(num_workers):
            req = store.cashiers.request()
            dummy_reqs.append(req)
            yield req  # once acquired, that slot stays busy

        # Time spent performing inventory
        yield env.timeout(duration)

        # Release these workers back to checkout
        for req in dummy_reqs:
            store.cashiers.release(req)


# ------------------------------------------------------------
# Customer Process
# ------------------------------------------------------------
def customer(env, name, store):
    arrival_time = env.now
    store.total_customers += 1

    # 1. Shopping
    shop_time = random.uniform(MIN_SHOP_TIME, MAX_SHOP_TIME)
    yield env.timeout(shop_time)

    # 2. Checkout choice: if kiosks exist, 50% chance of using them
    use_kiosk = store.kiosks and (random.random() < 0.5)
    checkout_resource = store.kiosks if use_kiosk else store.cashiers

    with checkout_resource.request() as req:
        patience = random.uniform(5, 15)
        result = yield req | env.timeout(patience)

        if req not in result:
            store.abandoned_customers += 1
            store.satisfaction_scores.append(2.0)
            return

        wait_time = env.now - arrival_time - shop_time
        store.wait_times.append(wait_time)

        basket_size = random.randint(MIN_BASKET_ITEMS, MAX_BASKET_ITEMS)
        checkout_time = basket_size * (0.25 if use_kiosk else 0.20)
        yield env.timeout(checkout_time)

        basket_value = basket_size * AVG_ITEM_PRICE
        basket_profit = basket_value * PROFIT_MARGIN
        thief = random.random() < THEFT_PROBABILITY

        if thief:
            # Theft detection: AI for A2/A3/A4, manual otherwise
            if store.scenario in ("A2", "A3", "A4"):
                catch_prob = AI_THEFT_CATCH_PROB
            else:
                catch_prob = CASHIER_CATCH_PROB

            if random.random() > catch_prob:
                store.theft_loss += basket_value
            # if caught ? no sale
        else:
            store.revenue += basket_value
            store.gross_profit += basket_profit

        # --- Updated Satisfaction Model ---
        # No penalty for first 1 minute
        # Small, gradually increasing penalty from 1–5 minutes
        # Strong penalty after 5 minutes
        penalty_wait = 0.0
        if wait_time <= 1.0:
            penalty_wait = 0.0
        elif wait_time <= 5.0:
            # up to about 0.4 points off at 5 minutes
            penalty_wait = 0.1 * (wait_time - 1.0)
        else:
            # stronger penalty after 5 minutes
            # starts at 0.4 and adds 1 point per extra minute
            penalty_wait = 0.4 + 1.0 * (wait_time - 5.0)

        penalty_kiosk = 0.5 if use_kiosk else 0.0

        satisfaction = 10.0 - (penalty_wait + penalty_kiosk)
        store.satisfaction_scores.append(max(0.0, satisfaction))


# ------------------------------------------------------------
# Customer Generator
# ------------------------------------------------------------
def customer_generator(env, store):
    i = 0
    while True:
        yield env.timeout(random.expovariate(1.0 / store.get_arrival_interval()))
        i += 1
        env.process(customer(env, f"C{i}", store))


# ------------------------------------------------------------
# Run Simulation
# ------------------------------------------------------------
def run_simulation(store_size, scenario):
    env = simpy.Environment()
    store = Store(env, store_size, scenario)

    env.process(customer_generator(env, store))
    env.process(inventory_process(env, store))  # does nothing for A4/A5

    env.run(until=SIM_TIME)
    summary = store.summarize_and_print()
    RESULTS.append(summary)


# ------------------------------------------------------------
# Summary Tables (One table per store size)
# ------------------------------------------------------------
def print_summary_tables(results):
    print("\n\n==================== STORE SIZE SUMMARY TABLES ====================\n")

    # Abbreviations for each scenario
    SCENARIO_ABBR = {
        "A0": "Baseline",
        "A1": "SC",           # Self-checkout
        "A2": "AI-TP",        # AI Theft Prevention
        "A3": "SC+AI-TP",     # Self-checkout + AI Theft Prevention
        "A4": "Full-Auto",    # SC + AI-TP + Inventory AI
        "A5": "Inv-AI"        # Inventory AI only
    }

    store_sizes = ["Small", "Medium", "Large"]
    scenarios = ["A0", "A1", "A2", "A3", "A4", "A5"]

    for store in store_sizes:
        print(f"=== {store.upper()} Store Summary ===")
        print(f"{'Scenario':<12} {'NetProfit':>12} {'Satisf':>8} {'Abandon%':>10} {'AvgWait':>8} {'Revenue':>12}")
        print("-" * 76)

        # Filter store rows
        rows = [r for r in results if r["store"] == store]

        for sc in scenarios:
            rlist = [r for r in rows if r["scenario"] == sc]
            if not rlist:
                continue
            r = rlist[0]

            label = f"{sc} ({SCENARIO_ABBR[sc]})"

            print(f"{label:<12} "
                  f"{r['net_profit']:>12.2f} "
                  f"{r['avg_satisfaction']:>8.2f} "
                  f"{r['abandon_rate']:>10.2f} "
                  f"{r['avg_wait']:>8.2f} "
                  f"{r['revenue']:>12.2f}")

        print()  # spacing between tables


# ------------------------------------------------------------
# Main
# ------------------------------------------------------------
if __name__ == "__main__":
    print("=== Running Full Automation Simulation (A0–A5) ===")
    for s in ["Small", "Medium", "Large"]:
        for sc in ["A0", "A1", "A2", "A3", "A4", "A5"]:
            run_simulation(s, sc)

    # Print the per-store summary tables at the very end
    print_summary_tables(RESULTS)
