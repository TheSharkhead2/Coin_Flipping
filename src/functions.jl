module SimAnnealCoin

using Statistics, Distributions, ProgressMeter

export simulation

"""
Simulation with certain threshold for stopping flipping a coin

# Parameters 

## n
Number of rounds 

## p 
Proportion to stop at (of heads)

# Returns 

## proportion
The average proportion recieved

"""
function simulation(n::Int, p::Float64)
    results = Vector{Float64}() # Vector of results
    for i in 1:n # run n rounds 
        flip = rand() # first flip
        if flip < 0.5
            numberHeads = 1
            numberFlips = 1
        else
            numberFlips = 1
            numberHeads = 0
        end
        while numberHeads/numberFlips < p # while proportion of heads is less than p
            flip = rand() # flip a coin
            if flip < 0.5 # if heads
                numberHeads = numberHeads + 1 # increment number of heads
            end # if 
            numberFlips = numberFlips + 1 # increment number of flips


            if numberFlips >= 1000000 # if number of flips is greater than 1000000 (prevent overflow)
                break # break
            end # if

        end # while
        push!(results, numberHeads/numberFlips) # push proportion of heads to results
    end # for 

    mean(results)
end # function simulation

"""
Get the neighbors for a given proportion 

"""
function get_neighbor(p::Float64; stepStdev::Float64=0.01)
    neighbor = rand(Normal(p, stepStdev)) # get a random neighbor

    if neighbor < 0.0 # if neighbor is less than 0
        neighbor = 0.0 # set neighbor to 0
    elseif neighbor > 1.0
        neighbor = 1.0 # set neighbor to 1
    end # if
    neighbor
end # function get_neighbor

export sim_anneal

""" 
Run simulated annealing to find the best proportion

"""
function sim_anneal(iTemp::Float64, fTemp::Float64, rounds::Int, beta::Float64)
    p = rand() # get a random starting point

    println("Starting with random stopping proportion of ", p)

    temp = iTemp # initial temperature is current temperature

    currentScore = simulation(rounds, p) # get the score of the starting point

    prog = ProgressThresh(fTemp, "Temperature:") #Progressbar
    while temp > fTemp # loop until temperature is at final temp
        neighbor = get_neighbor(p) # get a neighbor

        neighborScore = simulation(rounds, neighbor) # get the score of the neighbor

        costDiff = neighborScore - currentScore # get the difference in score

        if costDiff > 0 # if the neighbor is better
            p = neighbor # set the new point
            currentScore = neighborScore # set the new score
        else # if the neighbor is worse
            if rand() < exp(costDiff/temp) # if the neighbor is worse but we accept it by some function of the temperature
                p = neighbor # set the new point
                currentScore = neighborScore # set the new score
            end # if
        end # if

        #decrement the temperature 
        temp = temp/(1+beta*temp) #smaller the beta, the slower the decreases

        ProgressMeter.update!(prog, temp) #update bar
    end # while

    println("Found proportion of ", p, " with score ", currentScore)

end # function sim_anneal


end # module SimAnnealCoin