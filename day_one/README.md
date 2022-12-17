## Haskell

On Apple M1:

```text
All
  naive:  OK (1.67s)
    1.61 ms ± 126 μs
  flat:   OK (1.33s)
    20.2 μs ± 1.9 μs
  mmaped: OK (2.40s)
    18.2 μs ± 936 ns
```

## Rust

```rust
#[derive(Default)]
struct State {
    inner: [u64; 4],
}

impl State {
    fn add(mut self, value: u64) -> Self {
        if value <= self.inner[0] {
            self
        } else {
            self.inner[0] = value;
            self.inner.sort();
            self
        }
    }

    fn sum_three(self) -> u64 {
        self.inner[1..].iter().sum()
    }
}

fn flat(source: &[u8]) -> Result<u64, Box<dyn std::error::Error>> {
    fn helper(source: &[u8]) -> IResult<&[u8], u64> {
        let block_sum = tuple((
            fold_many1(
                tuple((nom::character::complete::u64, line_ending)).map(|(n, _)| n),
                || 0,
                |acc, row| acc + row,
            ),
            char('\n'),
        ))
        .map(|(n, _)| n);

        let mut blocks_map =
            fold_many0(block_sum, State::default, State::add).map(State::sum_three);

        blocks_map.parse(source)
    }

    let result = helper(source)
        .map(|(_rest, result)| result)
        .map_err(|e| e.to_string())?;

    Ok(result)
}

pub fn buffered<P: AsRef<Path>>(path: P) -> Result<u64, Box<dyn std::error::Error>> {
    let source = std::fs::read(path)?;
    flat(&source)
}

pub fn mmaped<P: AsRef<Path>>(path: P) -> Result<u64, Box<dyn std::error::Error>> {
    let source = std::fs::File::open(path)?;
    let source = unsafe { memmap2::Mmap::map(&source) }?;
    flat(&source)
}
```

```text
     Running benches/benchmark.rs (target/release/deps/benchmark-3eb26d1f483bd8a9)
flat buffered           time:   [21.800 µs 21.852 µs 21.913 µs]
Found 1 outliers among 100 measurements (1.00%)
  1 (1.00%) high severe

flat mmaped             time:   [22.293 µs 22.364 µs 22.436 µs]
Found 5 outliers among 100 measurements (5.00%)
  4 (4.00%) high mild
  1 (1.00%) high severe
```