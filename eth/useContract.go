package main

import (
	"context"
	"eth/test/ts"
	"fmt"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
	"log"
	"math/big"
)

const (
	contractAddr = "0x0fFb8C6765B5AdF0f33d2E96e669bC2402c97BCF"
)

func main() {
	client, err := ethclient.Dial("https://sepolia.infura.io/v3/199ab803cb1b4029b93e78f410880ad2")
	if err != nil {
		log.Fatal(err)
	}
	testContract, err := ts.NewTs(common.HexToAddress(contractAddr), client)
	if err != nil {
		log.Fatal(err)
	}

	privateKey, err := crypto.HexToECDSA("key")
	if err != nil {
		log.Fatal(err)
	}

	chainID, err := client.NetworkID(context.Background())
	if err != nil {
		log.Fatal(err)
	}

	opt, err := bind.NewKeyedTransactorWithChainID(privateKey, chainID)
	if err != nil {
		log.Fatal(err)
	}
	count := big.NewInt(3)
	tx, err := testContract.Increase(opt, count)
	fmt.Println(tx, err)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("tx hash:", tx.Hash().Hex())

	callOpt := &bind.CallOpts{Context: context.Background()}
	valueInContract, err := testContract.Account(callOpt)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("is value saving in contract equals to origin value:", valueInContract)
}
