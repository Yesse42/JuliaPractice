function MontyHallGuess()
    #First get the door the car is behind
    car_door=rand(1:3)
    #Then get the door you guess initially
    initial_guess=rand(1:3)
    #Then get the door the emcee chooses to reveal, which is not the car door
    emcee_reveal=rand(filter(x->!(x==car_door),1:3))
    #Then get your changed guess
    changed_guess=first(filter(x->!((x==emcee_reveal)||(x==initial_guess)),1:3))
    #Return the results in a named tuple
    return (init_guess = (car_door==initial_guess), change_guess = (changed_guess==car_door))
end

function main()
    total=10000
    init_guess_correct=0
    changed_guess_correct=0
    for i in 1:total
        out=MontyHallGuess()
        init_guess_correct+=out.init_guess
        changed_guess_correct+=out.change_guess
    end
    init_percent=round(big(init_guess_correct)/total,digits=6)
    changed_percent=round(big(changed_guess_correct)/total,digits=6)
    println("The initial guesses were correct $init_percent of the time and the changed guesses were correct $changed_percent of the time")
end

main()