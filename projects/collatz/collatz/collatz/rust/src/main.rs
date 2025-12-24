use std::env;

#[derive(Clone)]
struct ColNum
{
	n: i64,
	len: i64,
}

fn col(mut i: i64) -> i64
{
	let mut length: i64 = i;

	while i != 1
	{
		if i % 2 == 0
		{
			i = i / 2;
		}
		else
		{
			i = i * 3 + 1;
		}
		if i > length
        {
            length = i;   
        }
	}

	return length;
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

	let arg1 = &args[1];
	let arg2 = &args[2];
    let mm1 = &arg1[0..2];
    let dd1 = &arg1[3..5];
    let y1 = &arg1[6..10];
    let mm2 = &arg2[0..2];
    let dd2 = &arg2[3..5];
    let y2 = &arg2[6..10];
    let s1 = format!("{}{}{}", mm1, dd1, y1);
    let s2 = format!("{}{}{}", mm2, dd2, y2);
	let start: i64 = s1.parse().unwrap();
	let finish: i64 = s2.parse().unwrap();

	let mut arr: Vec<ColNum> = Vec::new();

	let mut min_index: usize = 0;

	let mut i = start;
	while i <= finish
	{
		let mut duplicate = false;
		let len = col(i);

		// check duplicate lengths
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

	len_sort(&mut arr);
    println!("Sorted based on sequence length");
    let mut i = 0;
    while i < arr.len()
    {
        println!("{:>20}{:>20}",arr[i].n, arr[i].len);
        i += 1;
    }
    println!("{}", arr[0].len); 
    i = 0;
	num_sort(&mut arr);
    println!("Sorted based on integer size");
    while i < arr.len()
    {
        println!("{:>20}{:>20}",arr[i].n, arr[i].len);
        i += 1;
    }
}

