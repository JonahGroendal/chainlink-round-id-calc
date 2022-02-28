const BN = web3.utils.BN
const TestContract = artifacts.require("TestContract")

const toWei = amount => (new BN(amount*10000000000)).mul((new BN(10)).pow(new BN(8)))

contract("Swap", accounts => {
    let math;

    beforeEach(async () => {
        t = await TestContract.deployed()
    })


    it("should get the latest price", async () => {
        const price = await t.getLatestPrice.call();
        console.log(price.toString())

        assert(price.gt(new BN(0)))
    })

    it("should get the previous roundId", async () => {
        const latestId = await t.getLatestRoundId.call();
        const prevId = await t.prev.call(latestId)
        console.log(prevId.toString())

        assert(prevId.lt(latestId));
    })

    it("should get the previous price", async () => {
        const latestId = await t.getLatestRoundId.call();
        const prevId = await t.prev.call(latestId)
        const price = await t.getHistoricalPrice.call(prevId)

        console.log(price.toString())

        assert(price.gt(new BN(0)))
    })

    it("should get the next roundId", async () => {
        const latestId = await t.getLatestRoundId.call();
        const prevId = await t.prev.call(latestId);
        const nextId = await t.next.call(prevId);

        console.log(nextId.toString())

        assert.equal(latestId.toString(), nextId.toString());
    })

    it("should return same roundId when can't get next", async () => {
        const latestId = await t.getLatestRoundId.call();
        const nextId = await t.next.call(latestId);

        console.log(nextId.toString())

        assert.equal(latestId.toString(), nextId.toString());
    })

    it("should transition smoothly to previous phase", async () => {
        const p2r1Id = await t.addPhase.call(new BN(2), new BN(1))
        const prevId = await t.prev.call(p2r1Id)

        console.log(await t.parseIds.call(p2r1Id))
        console.log(await t.parseIds.call(prevId))

        assert(prevId.lt(p2r1Id))
        assert(prevId.gt(new BN(0)))
    })

    // it("should transition smoothly to next phase", async () => {
    //     const p2r1Id = await t.addPhase.call(new BN(1), new BN(1))
    //     const prevId = await t.prev.call(p2r1Id)

    //     console.log(await t.parseIds.call(p2r1Id))

    //     assert(prevId.lt(p2r1Id))
    //     assert(prevId.gt(new BN(0)))
    // })
    
})