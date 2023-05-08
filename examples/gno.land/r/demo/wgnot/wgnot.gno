package wgnot

import (
	"std"
	"strings"

	"gno.land/p/demo/grc/grc20"
	"gno.land/p/demo/ufmt"
	"gno.land/r/demo/users"
)

var (
	foo *grc20.AdminToken
)

func init() {
	foo = grc20.NewAdminToken("Wrapped GNOT", "WGNOT", 6)
}

func Deposit() {
	caller := std.GetOrigCaller()
	sentCoins := std.GetOrigSend()
	if len(sentCoins) != 1 {
		panic("invalid origin send")
	}
	if sentCoins[0].Denom == "ugnot" && sentCoins[0].Amount > 0 {
		if err := mint(caller, uint64(sentCoins[0].Amount)); err != nil {
			panic(err)
		}
	} else {
		panic("invalid origin send")
	}
}

func Withdraw(amount uint64) {
	caller := std.GetOrigCaller()
	balance := balanceOf(caller)
	if balance < amount {
		panic("insufficient balance")
	}
	burn(caller, amount)
	banker := std.GetBanker(std.BankerTypeRealmSend)
	pkgaddr := std.GetOrigPkgAddr()
	send := std.Coins{{"ugnot", int64(amount)}}
	banker.SendCoins(pkgaddr, caller, send)
}

func Name() string {
	return foo.GetName()
}

func Symbol() string {
	return foo.GetSymbol()
}

func Decimals() uint {
	return foo.GetDecimals()
}

func TotalSupply() uint64 {
	return foo.TotalSupply()
}

func BalanceOf(owner users.AddressOrName) uint64 {
	return balanceOf(owner.Resolve())
}

func Allowance(owner, spender users.AddressOrName) uint64 {
	allowance, err := foo.Allowance(owner.Resolve(), spender.Resolve())
	if err != nil {
		panic(err)
	}
	return allowance
}

func Transfer(to users.AddressOrName, amount uint64) {
	caller := std.GetOrigCaller()
	foo.Transfer(caller, to.Resolve(), amount)
}

func Approve(spender users.AddressOrName, amount uint64) {
	caller := std.GetOrigCaller()
	foo.Approve(caller, spender.Resolve(), amount)
}

func TransferFrom(from, to users.AddressOrName, amount uint64) {
	caller := std.GetOrigCaller()
	foo.TransferFrom(caller, from.Resolve(), to.Resolve(), amount)
}

func balanceOf(owner std.Address) uint64 {
	balance, err := foo.BalanceOf(owner)
	if err != nil {
		panic(err)
	}
	return balance
}

func mint(address std.Address, amount uint64) error {
	return foo.Mint(address, amount)
}

func burn(address std.Address, amount uint64) {
	foo.Burn(address, amount)
}

func Render(path string) string {
	parts := strings.Split(path, "/")
	c := len(parts)
	switch {
	case path == "":
		return foo.RenderHome()
	case c == 2 && parts[0] == "balance":
		owner := users.AddressOrName(parts[1])
		balance, _ := foo.BalanceOf(owner.Resolve())
		return ufmt.Sprintf("%d\n", balance)
	default:
		return "404\n"
	}
}
