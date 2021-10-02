#An attempt at making a generic n-body simulator
using StaticArrays, Base.Threads

"First define a struct to hold a single body"
struct Mass{T<:AbstractFloat}
    m::T
    q::T
    r::Array{T,1}
    v::Array{T,1}
    olda::Array{T,1} #Here to allow for much more efficient leapfrogging
    a::Array{T,1}
end

"Define a convenience constructor with garbage acceleration values; they will be reset anyways"
function Mass(mass::T,pos,vel) where T
    q=convert(T,0)
    acceleration=similar(pos)
    oldacc=similar(acceleration)
    return Mass(mass,q,pos,vel,acceleration,oldacc)
end

"A nice rename if you want to highlight that they have charges"
function Charge(mass,q,pos,vel)
    acceleration=similar(pos)
    oldacc=similar(acceleration)
    return Mass(mass,q,pos,vel,acceleration,oldacc)
end

"Another way to make a charged particle whilst retaining the type name"
function Mass(mass,q,pos,vel)
    acceleration=similar(pos)
    oldacc=similar(acceleration)
    return Mass(mass,q,pos,vel,acceleration,oldacc)
end

"And define a struct to hold the whole sim at time T"
struct NBodySim{T<:AbstractFloat}
    t0::T
    t_final::T
    dt::T
    save_every::T
    forcefunc::Function
    bodies::Vector{Mass{T}}
    bodypairs::Vector{Tuple{Int64,Int64}}
end

let G=1.0e-3
    "Generic Gravity, intakes two bodies, outputs the magnitude of gravity, always positive"
    global function gravity(b1::Mass{T},b2::Mass{T})::T where {T<:AbstractFloat}
        #squaredist=sum((P2-P1)^2 for P1 in p1, P2 in p2)
        squaredist=0
        for i in eachindex(b1.r)
            @inbounds squaredist+=(b2.r[i]-b1.r[i])^2
        end
        if isapprox(squaredist,0;atol=0.125)
            return T(0)
        else
            return (G*b1.m*b2.m/(squaredist^(1.5)))
        end
    end
end

"A constructor which generates the body pairs"
function NBodySim(bodies::Array;t0=0.,tfinal=60.,dt=1.,saveinterval=5.,forcefunction=gravity)
    #This avoids duplicate pairs
    pairs=collect((i,j) for i in eachindex(bodies) for j in 1:(i-1))
    return NBodySim(t0,tfinal,dt,saveinterval,forcefunction,bodies,pairs)
end

"Calculates the total acceleration for each body"
function accelerate!(sim::NBodySim,forcefunction)
    #reset the acceleration
    for bod in sim.bodies
        bod.a.=0
    end
    for (i,j) in sim.bodypairs
        if i==j
            continue
        end
        bod1=sim.bodies[i]
        bod2=sim.bodies[j]
        grav=forcefunction(bod1,bod2)
        #Inbounds loops are ~35% more efficient than nice broadcasted code
        # bod1.a.+=grav.*(1/m1).*(p2.-p1)
        # bod2.a.+=grav.*(1/m2).*(p2.-p1)
        for i in eachindex(bod1.a)
            @inbounds bod1.a[i]+=(1/bod1.m)*grav*(bod2.r[i]-bod1.r[i])
            @inbounds bod2.a[i]+=(1/bod2.m)*grav*(bod1.r[i]-bod2.r[i])
        end
    end
    return nothing
end

"Move 1 timestep forward, using a time-reversible leapfrog integrator to prevent excessive energy drift"
function step!(sim::NBodySim)
    #Calculate the acceleration due to gravity for each body pair, and add it into the acceleration array for that body, using the principle of superposition
    #Now actually calculate the accelerate
    accelerate!(sim,sim.forcefunc)
    #Now use leapfrog integration to step the planets about, and then archive the old accelerations for the next leapfroggening
    for bod in sim.bodies
        # bod.r.=@.(bod.r+bod.v*sim.dt+sim.dt^2*bod.a/2)
        # bod.olda.=bod.a
        for i in eachindex(bod.r)
            @inbounds bod.r[i]+=bod.v[i]*sim.dt+sim.dt^2*bod.a[i]/2
            @inbounds bod.olda[i]=bod.a[i]
        end
    end
    #The leapfrog integrator demands the acceleration at the next timestep too, so get that
    accelerate!(sim,sim.forcefunc)
    #And now use it to update the velocities
    for bod in sim.bodies
        #bod.v.+=@.(sim.dt*(bod.a+bod.olda)/2)
        for i in eachindex(bod.v)
            @inbounds bod.v[i]+=sim.dt*(bod.a[i]+bod.olda[i])*0.5
        end
    end
    #Don't return, as everything is in place
    return nothing
end

function run!(sim::NBodySim;savebool=false)
    t=sim.t0
    savetime=sim.t0+sim.save_every
    savearr=[]
    tvec=[]
    while t<sim.t_final
        step!(sim)
        t=t+sim.dt
        if savebool
            if t>savetime
                #Is this lazy? Yes! Do I care? No!.
                append!(savearr,deepcopy([sim]))
                append!(tvec,[t])
                while savetime<t
                    savetime+=sim.save_every
                end
            end
        end
    end
    return (sim,savearr,tvec)
end