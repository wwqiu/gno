package main

import (
	"std"

	"gno.land/r/demo/wgnot"
	"gno.land/r/demo/users"
)

func main() {
	caller := users.AddressOrName("g1us8428u2a5satrlxzagqqa5m6vmuze025anjlj")
	std.TestSetOrigCaller(caller.Resolve())
	wgnot.Withdraw(50000000)
	balance := wgnot.BalanceOf(caller)
	println("balance:", balance)
}

// Error:
// insufficient balance
