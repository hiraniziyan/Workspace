use std::env;

#[derive(Clone)]
struct ColNum
{
    n: i64,
	len: i64,
}

fn rec_col(i: i64) -> i64
{
	if i == 1
	{
		return 0;
	}
	else if i % 2 == 0
	{
		let next = i / 2;
		return 1 + rec_col(next);
	}
	else
	{
		let next = i * 3 + 1;
		return 1 + rec_col(next);
	}
}

fn find_min_index(arr: &Vec<ColNum>) -> usize
{
	let mut min_len = arr[0].len;
	let mut min_index: usize = 0;

	let mut i: usize = 1;
	while i < arr.len()
	{
		if arr[i].len < min_len
		{
			min_len = arr[i].len;
			min_index = i;
		}
		i += 1;
	}

	return min_index;
}

fn len_sort(arr: &mut Vec<ColNum>)
{
	let k = arr.len();
	let mut i: usize = 0;

	while i < k - 1
	{
		let mut j: usize = 0;
		while j < k - 1 - i
		{
			if arr[j].len < arr[j + 1].len
			{
				let temp = arr[j].clone();
				arr[j] = arr[j + 1].clone();
				arr[j + 1] = temp;
			}
			j += 1;
		}
		i += 1;
	}
}

fn num_sort(arr: &mut Vec<ColNum>)
{
	let k = arr.len();
	let mut i: usize = 0;

	while i < k - 1
	{
		let mut j: usize = 0;
		while j < k - 1 - i
		{
			if arr[j].n < arr[j + 1].n
			{
				let temp = arr[j].clone();
				arr[j] = arr[j + 1].clone();
				arr[j + 1] = temp;
			}
			j += 1;
		}
		i += 1;
	}
}

fn main()
{
	let args: Vec<String> = env::args().collect();

	let finish: i64 = args[2].parse().unwrap();
	let start: i64 = args[1].parse().unwrap();

	let mut arr: Vec<ColNum> = Vec::new();
	let mut min_index: usize = 0;

	let mut i = start;
	while i <= finish
	{
		let mut duplicate = false;
		let len = rec_col(i);

		// Check for duplicate lengths
		let mut j: usize = 0;
		while j < arr.len()
		{
			if arr[j].len == len
			{
				duplicate = true;
				break;
			}
			j += 1;
		}

		if arr.len() < 10 && !duplicate
		{
			arr.push(ColNum { n: i, len });
			min_index = find_min_index(&arr);
		}
		else if !duplicate && len > arr[min_index].len
		{
			arr[min_index] = ColNum { n: i, len };
			min_index = find_min_index(&arr);
		}

		i += 1;
	}

	// Sort by length
	len_sort(&mut arr);
	println!("Sorted based on sequence length");

	let mut i = 0;
	while i < arr.len()
	{
		println!("{:>20}{:>20}", arr[i].n, arr[i].len);
		i += 1;
	}

	// Sort by integer value
	num_sort(&mut arr);
	println!("Sorted based on integer size");

	i = 0;
	while i < arr.len()
	{
		println!("{:>20}{:>20}", arr[i].n, arr[i].len);
		i += 1;
	}
}
