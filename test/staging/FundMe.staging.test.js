const { assert } = require("chai")
const { getNamedAccounts, ethers } = require("hardhat")
const { developmentChain } = require("../../helper-hardhat-config")

//if not on dev chain run
developmentChain.includes(network.name)
    ? describe.skip
    : describe("FundMe", async function () {
          let fundMe
          let deployer
          const sendValue = ethers.utils.parseEther("10")
          beforeEach(async function () {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })

          it("allows people to fund and withdraw", async function () {
              await fundMe.fund({
                  value: sendValue,
              })
              await fundMe.withdraw()
              const endingBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )

              assert.equal(endingBalance.toString(), "0")
          })
      })
