// Code generated - DO NOT EDIT.
// This file is a generated binding and any manual changes will be lost.

package ts

import (
	"errors"
	"math/big"
	"strings"

	ethereum "github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
)

// Reference imports to suppress errors if they are not otherwise used.
var (
	_ = errors.New
	_ = big.NewInt
	_ = strings.NewReader
	_ = ethereum.NotFound
	_ = bind.Bind
	_ = common.Big1
	_ = types.BloomLookup
	_ = event.NewSubscription
	_ = abi.ConvertType
)

// TsMetaData contains all meta data concerning the Ts contract.
var TsMetaData = &bind.MetaData{
	ABI: "[{\"inputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"constructor\"},{\"anonymous\":false,\"inputs\":[{\"indexed\":true,\"internalType\":\"uint256\",\"name\":\"count\",\"type\":\"uint256\"}],\"name\":\"success\",\"type\":\"event\"},{\"inputs\":[],\"name\":\"account\",\"outputs\":[{\"internalType\":\"uint256\",\"name\":\"\",\"type\":\"uint256\"}],\"stateMutability\":\"view\",\"type\":\"function\"},{\"inputs\":[{\"internalType\":\"uint256\",\"name\":\"amount\",\"type\":\"uint256\"}],\"name\":\"increase\",\"outputs\":[],\"stateMutability\":\"nonpayable\",\"type\":\"function\"}]",
	Bin: "0x6080604052348015600e575f5ffd5b5060015f819055506101df806100235f395ff3fe608060405234801561000f575f5ffd5b5060043610610034575f3560e01c806330f3f0db146100385780635dab242014610054575b5f5ffd5b610052600480360381019061004d91906100f6565b610072565b005b61005c6100ba565b6040516100699190610130565b60405180910390f35b805f5f8282546100829190610176565b925050819055505f547f888ea2435479e7986dcaef778dfd65df5aeb458b8d46acb3889df43451838da560405160405180910390a250565b5f5481565b5f5ffd5b5f819050919050565b6100d5816100c3565b81146100df575f5ffd5b50565b5f813590506100f0816100cc565b92915050565b5f6020828403121561010b5761010a6100bf565b5b5f610118848285016100e2565b91505092915050565b61012a816100c3565b82525050565b5f6020820190506101435f830184610121565b92915050565b7f4e487b71000000000000000000000000000000000000000000000000000000005f52601160045260245ffd5b5f610180826100c3565b915061018b836100c3565b92508282019050808211156101a3576101a2610149565b5b9291505056fea2646970667358221220f39a84c9ab53e6ddb3f5e098d5dbff2361fe1f6af14c95326e6c469c95ae5cff64736f6c634300081e0033",
}

// TsABI is the input ABI used to generate the binding from.
// Deprecated: Use TsMetaData.ABI instead.
var TsABI = TsMetaData.ABI

// TsBin is the compiled bytecode used for deploying new contracts.
// Deprecated: Use TsMetaData.Bin instead.
var TsBin = TsMetaData.Bin

// DeployTs deploys a new Ethereum contract, binding an instance of Ts to it.
func DeployTs(auth *bind.TransactOpts, backend bind.ContractBackend) (common.Address, *types.Transaction, *Ts, error) {
	parsed, err := TsMetaData.GetAbi()
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	if parsed == nil {
		return common.Address{}, nil, nil, errors.New("GetABI returned nil")
	}

	address, tx, contract, err := bind.DeployContract(auth, *parsed, common.FromHex(TsBin), backend)
	if err != nil {
		return common.Address{}, nil, nil, err
	}
	return address, tx, &Ts{TsCaller: TsCaller{contract: contract}, TsTransactor: TsTransactor{contract: contract}, TsFilterer: TsFilterer{contract: contract}}, nil
}

// Ts is an auto generated Go binding around an Ethereum contract.
type Ts struct {
	TsCaller     // Read-only binding to the contract
	TsTransactor // Write-only binding to the contract
	TsFilterer   // Log filterer for contract events
}

// TsCaller is an auto generated read-only Go binding around an Ethereum contract.
type TsCaller struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// TsTransactor is an auto generated write-only Go binding around an Ethereum contract.
type TsTransactor struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// TsFilterer is an auto generated log filtering Go binding around an Ethereum contract events.
type TsFilterer struct {
	contract *bind.BoundContract // Generic contract wrapper for the low level calls
}

// TsSession is an auto generated Go binding around an Ethereum contract,
// with pre-set call and transact options.
type TsSession struct {
	Contract     *Ts               // Generic contract binding to set the session for
	CallOpts     bind.CallOpts     // Call options to use throughout this session
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// TsCallerSession is an auto generated read-only Go binding around an Ethereum contract,
// with pre-set call options.
type TsCallerSession struct {
	Contract *TsCaller     // Generic contract caller binding to set the session for
	CallOpts bind.CallOpts // Call options to use throughout this session
}

// TsTransactorSession is an auto generated write-only Go binding around an Ethereum contract,
// with pre-set transact options.
type TsTransactorSession struct {
	Contract     *TsTransactor     // Generic contract transactor binding to set the session for
	TransactOpts bind.TransactOpts // Transaction auth options to use throughout this session
}

// TsRaw is an auto generated low-level Go binding around an Ethereum contract.
type TsRaw struct {
	Contract *Ts // Generic contract binding to access the raw methods on
}

// TsCallerRaw is an auto generated low-level read-only Go binding around an Ethereum contract.
type TsCallerRaw struct {
	Contract *TsCaller // Generic read-only contract binding to access the raw methods on
}

// TsTransactorRaw is an auto generated low-level write-only Go binding around an Ethereum contract.
type TsTransactorRaw struct {
	Contract *TsTransactor // Generic write-only contract binding to access the raw methods on
}

// NewTs creates a new instance of Ts, bound to a specific deployed contract.
func NewTs(address common.Address, backend bind.ContractBackend) (*Ts, error) {
	contract, err := bindTs(address, backend, backend, backend)
	if err != nil {
		return nil, err
	}
	return &Ts{TsCaller: TsCaller{contract: contract}, TsTransactor: TsTransactor{contract: contract}, TsFilterer: TsFilterer{contract: contract}}, nil
}

// NewTsCaller creates a new read-only instance of Ts, bound to a specific deployed contract.
func NewTsCaller(address common.Address, caller bind.ContractCaller) (*TsCaller, error) {
	contract, err := bindTs(address, caller, nil, nil)
	if err != nil {
		return nil, err
	}
	return &TsCaller{contract: contract}, nil
}

// NewTsTransactor creates a new write-only instance of Ts, bound to a specific deployed contract.
func NewTsTransactor(address common.Address, transactor bind.ContractTransactor) (*TsTransactor, error) {
	contract, err := bindTs(address, nil, transactor, nil)
	if err != nil {
		return nil, err
	}
	return &TsTransactor{contract: contract}, nil
}

// NewTsFilterer creates a new log filterer instance of Ts, bound to a specific deployed contract.
func NewTsFilterer(address common.Address, filterer bind.ContractFilterer) (*TsFilterer, error) {
	contract, err := bindTs(address, nil, nil, filterer)
	if err != nil {
		return nil, err
	}
	return &TsFilterer{contract: contract}, nil
}

// bindTs binds a generic wrapper to an already deployed contract.
func bindTs(address common.Address, caller bind.ContractCaller, transactor bind.ContractTransactor, filterer bind.ContractFilterer) (*bind.BoundContract, error) {
	parsed, err := TsMetaData.GetAbi()
	if err != nil {
		return nil, err
	}
	return bind.NewBoundContract(address, *parsed, caller, transactor, filterer), nil
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Ts *TsRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Ts.Contract.TsCaller.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Ts *TsRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Ts.Contract.TsTransactor.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Ts *TsRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Ts.Contract.TsTransactor.contract.Transact(opts, method, params...)
}

// Call invokes the (constant) contract method with params as input values and
// sets the output to result. The result type might be a single field for simple
// returns, a slice of interfaces for anonymous returns and a struct for named
// returns.
func (_Ts *TsCallerRaw) Call(opts *bind.CallOpts, result *[]interface{}, method string, params ...interface{}) error {
	return _Ts.Contract.contract.Call(opts, result, method, params...)
}

// Transfer initiates a plain transaction to move funds to the contract, calling
// its default method if one is available.
func (_Ts *TsTransactorRaw) Transfer(opts *bind.TransactOpts) (*types.Transaction, error) {
	return _Ts.Contract.contract.Transfer(opts)
}

// Transact invokes the (paid) contract method with params as input values.
func (_Ts *TsTransactorRaw) Transact(opts *bind.TransactOpts, method string, params ...interface{}) (*types.Transaction, error) {
	return _Ts.Contract.contract.Transact(opts, method, params...)
}

// Account is a free data retrieval call binding the contract method 0x5dab2420.
//
// Solidity: function account() view returns(uint256)
func (_Ts *TsCaller) Account(opts *bind.CallOpts) (*big.Int, error) {
	var out []interface{}
	err := _Ts.contract.Call(opts, &out, "account")

	if err != nil {
		return *new(*big.Int), err
	}

	out0 := *abi.ConvertType(out[0], new(*big.Int)).(**big.Int)

	return out0, err

}

// Account is a free data retrieval call binding the contract method 0x5dab2420.
//
// Solidity: function account() view returns(uint256)
func (_Ts *TsSession) Account() (*big.Int, error) {
	return _Ts.Contract.Account(&_Ts.CallOpts)
}

// Account is a free data retrieval call binding the contract method 0x5dab2420.
//
// Solidity: function account() view returns(uint256)
func (_Ts *TsCallerSession) Account() (*big.Int, error) {
	return _Ts.Contract.Account(&_Ts.CallOpts)
}

// Increase is a paid mutator transaction binding the contract method 0x30f3f0db.
//
// Solidity: function increase(uint256 amount) returns()
func (_Ts *TsTransactor) Increase(opts *bind.TransactOpts, amount *big.Int) (*types.Transaction, error) {
	return _Ts.contract.Transact(opts, "increase", amount)
}

// Increase is a paid mutator transaction binding the contract method 0x30f3f0db.
//
// Solidity: function increase(uint256 amount) returns()
func (_Ts *TsSession) Increase(amount *big.Int) (*types.Transaction, error) {
	return _Ts.Contract.Increase(&_Ts.TransactOpts, amount)
}

// Increase is a paid mutator transaction binding the contract method 0x30f3f0db.
//
// Solidity: function increase(uint256 amount) returns()
func (_Ts *TsTransactorSession) Increase(amount *big.Int) (*types.Transaction, error) {
	return _Ts.Contract.Increase(&_Ts.TransactOpts, amount)
}

// TsSuccessIterator is returned from FilterSuccess and is used to iterate over the raw logs and unpacked data for Success events raised by the Ts contract.
type TsSuccessIterator struct {
	Event *TsSuccess // Event containing the contract specifics and raw log

	contract *bind.BoundContract // Generic contract to use for unpacking event data
	event    string              // Event name to use for unpacking event data

	logs chan types.Log        // Log channel receiving the found contract events
	sub  ethereum.Subscription // Subscription for errors, completion and termination
	done bool                  // Whether the subscription completed delivering logs
	fail error                 // Occurred error to stop iteration
}

// Next advances the iterator to the subsequent event, returning whether there
// are any more events found. In case of a retrieval or parsing error, false is
// returned and Error() can be queried for the exact failure.
func (it *TsSuccessIterator) Next() bool {
	// If the iterator failed, stop iterating
	if it.fail != nil {
		return false
	}
	// If the iterator completed, deliver directly whatever's available
	if it.done {
		select {
		case log := <-it.logs:
			it.Event = new(TsSuccess)
			if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
				it.fail = err
				return false
			}
			it.Event.Raw = log
			return true

		default:
			return false
		}
	}
	// Iterator still in progress, wait for either a data or an error event
	select {
	case log := <-it.logs:
		it.Event = new(TsSuccess)
		if err := it.contract.UnpackLog(it.Event, it.event, log); err != nil {
			it.fail = err
			return false
		}
		it.Event.Raw = log
		return true

	case err := <-it.sub.Err():
		it.done = true
		it.fail = err
		return it.Next()
	}
}

// Error returns any retrieval or parsing error occurred during filtering.
func (it *TsSuccessIterator) Error() error {
	return it.fail
}

// Close terminates the iteration process, releasing any pending underlying
// resources.
func (it *TsSuccessIterator) Close() error {
	it.sub.Unsubscribe()
	return nil
}

// TsSuccess represents a Success event raised by the Ts contract.
type TsSuccess struct {
	Count *big.Int
	Raw   types.Log // Blockchain specific contextual infos
}

// FilterSuccess is a free log retrieval operation binding the contract event 0x888ea2435479e7986dcaef778dfd65df5aeb458b8d46acb3889df43451838da5.
//
// Solidity: event success(uint256 indexed count)
func (_Ts *TsFilterer) FilterSuccess(opts *bind.FilterOpts, count []*big.Int) (*TsSuccessIterator, error) {

	var countRule []interface{}
	for _, countItem := range count {
		countRule = append(countRule, countItem)
	}

	logs, sub, err := _Ts.contract.FilterLogs(opts, "success", countRule)
	if err != nil {
		return nil, err
	}
	return &TsSuccessIterator{contract: _Ts.contract, event: "success", logs: logs, sub: sub}, nil
}

// WatchSuccess is a free log subscription operation binding the contract event 0x888ea2435479e7986dcaef778dfd65df5aeb458b8d46acb3889df43451838da5.
//
// Solidity: event success(uint256 indexed count)
func (_Ts *TsFilterer) WatchSuccess(opts *bind.WatchOpts, sink chan<- *TsSuccess, count []*big.Int) (event.Subscription, error) {

	var countRule []interface{}
	for _, countItem := range count {
		countRule = append(countRule, countItem)
	}

	logs, sub, err := _Ts.contract.WatchLogs(opts, "success", countRule)
	if err != nil {
		return nil, err
	}
	return event.NewSubscription(func(quit <-chan struct{}) error {
		defer sub.Unsubscribe()
		for {
			select {
			case log := <-logs:
				// New log arrived, parse the event and forward to the user
				event := new(TsSuccess)
				if err := _Ts.contract.UnpackLog(event, "success", log); err != nil {
					return err
				}
				event.Raw = log

				select {
				case sink <- event:
				case err := <-sub.Err():
					return err
				case <-quit:
					return nil
				}
			case err := <-sub.Err():
				return err
			case <-quit:
				return nil
			}
		}
	}), nil
}

// ParseSuccess is a log parse operation binding the contract event 0x888ea2435479e7986dcaef778dfd65df5aeb458b8d46acb3889df43451838da5.
//
// Solidity: event success(uint256 indexed count)
func (_Ts *TsFilterer) ParseSuccess(log types.Log) (*TsSuccess, error) {
	event := new(TsSuccess)
	if err := _Ts.contract.UnpackLog(event, "success", log); err != nil {
		return nil, err
	}
	event.Raw = log
	return event, nil
}
