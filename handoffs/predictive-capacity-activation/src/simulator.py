import random

# simple demand/supply simulation

def simulate():
    demand = random.randint(80,120)
    supply = random.randint(60,100)
    gap = demand - supply
    return demand, supply, gap

if __name__ == '__main__':
    d,s,g = simulate()
    print(f"Demand: {d}, Supply: {s}, Gap: {g}")
