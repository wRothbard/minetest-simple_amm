-- for testing lurkcoin integration w/out actually setting up lurkcoin

lurkcoin = {}
lurkcoin.bank = {}
lurkcoin.bank.monies = {}

function lurkcoin.bank.getbal(name)
    return lurkcoin.bank.monies[name] or 0
end

function lurkcoin.bank.add(name, amount, reason)
    if amount < 0 then
        return false
    end
    lurkcoin.bank.monies[name] = lurkcoin.bank.getbal(name) + amount
    smartshop.log("action", "[mock lurkcoin] added %s to %s's account (%s)", amount, name, reason)
end

function lurkcoin.bank.subtract(name, amount, reason)
    if amount < 0 then
        return false
    end
    lurkcoin.bank.monies[name] = lurkcoin.bank.getbal(name) - amount
    smartshop.log("action", "[mock lurkcoin] subtracted %s to %s's account (%s)", amount, name, reason)
end

function lurkcoin.bank.pay(from, to, amount)
    lurkcoin.bank.subtract(from, amount, "Transferring money to " .. to)
    lurkcoin.bank.add(from, amount, "Transferring money from " .. from)
end
