extern crate rand;

use rand::thread_rng;
use rand::Rng;

fn main() {
    let mut arr = [0i32; 8];
    thread_rng().try_fill(&mut arr[..]);
    println!("Random number array {:?}", arr);
}
