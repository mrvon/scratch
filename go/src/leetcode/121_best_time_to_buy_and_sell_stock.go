package main

import (
	"fmt"
	"math"
)

func maxProfit(prices []int) int {
	if len(prices) == 0 {
		return 0
	}

	min_price := math.MaxInt32
	max_profit := 0

	for i := 0; i < len(prices); i++ {
		if prices[i] < min_price {
			min_price = prices[i]
		} else {
			profix := prices[i] - min_price
			if profix > max_profit {
				max_profit = profix
			}
		}
	}

	return max_profit
}

func assert(expect int, result int) {
	if result != expect {
		panic(fmt.Sprintf("Assert failed!, Expect %d, Get %d", expect, result))
	}
}

func main() {
	assert(0, maxProfit([]int{0}))
	assert(5, maxProfit([]int{7, 1, 5, 3, 6, 4}))
	assert(6, maxProfit([]int{1, 2, 3, 4, 5, 7}))
	assert(0, maxProfit([]int{7, 6, 5, 4, 3, 2}))
	assert(1, maxProfit([]int{2, 1, 2, 0, 1}))
	assert(2, maxProfit([]int{2, 1, 2, 1, 0, 1, 2}))
	assert(8, maxProfit([]int{3, 4, 2, 1, 2, 0, 1, 7, 8, 0, 1}))
}
