//! A module to say hello world

use kernel::prelude::*;

module! {
    type: Hello,
    name: "hello",
    authors: ["me"],
    description: "my hellow world module",
    license: "GPL",
}

impl kernel::Module for Hello {
    fn init(_module: &'static ThisModule) -> Result<Self> {
        pr_info!("Hello World!\n");
        Ok(Hello {})
    }
}

impl Drop for Hello {
    fn drop(&mut self) {
        pr_info!("I'm dropped\n");
    }
}

struct Hello {}
