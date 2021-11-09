const datadir = "/Users/jerobinett/Desktop/NCEI_Airport_Processing/myncei"

using CSV, DataFrames, CairoMakie, Dates, Statistics, Dictionaries

airports=("KSAN","KNZY")

var = "uwind"

varname = "Mean Temperature (ºC)"

processfunc=x->x

files = joinpath.(datadir, airports .* ".csv")

dfs=CSV.read.(files, DataFrame)

newnames=[[if name == "datetime" "datetime" else airport*name end for name in names(df)] for (df, airport) in zip(dfs, airports)]

rename!.(dfs, newnames)

alldata=outerjoin(dfs...; on=:datetime)

sort!(alldata, :datetime)

transform!(alldata, :datetime=>ByRow(x->x-Hour(7))=>:datetime)

timefuncs=(time->year(round(time, Year(5), RoundDown)), time->hour(round(time, Hour(6), RoundDown)))
timefuncnames=("yearperiod", "hoursofday")

covernames = filter(x->occursin(var, x), names(alldata))

#Restrict to May and June

filter!(x->5<=month(x.datetime)<=6, alldata)

coverdata = select(alldata, (:datetime.=>ByRow.(timefuncs).=>timefuncnames)..., covernames.=>ByRow(processfunc).=>covernames)

grouped = groupby(coverdata, [:hoursofday, :yearperiod])

combined = combine(grouped, valuecols(grouped).=>(x->mean(skipmissing(x))).=>valuecols(grouped))

hoursofday = distinct(combined.hoursofday)

hournames = ["$hour-$(hour+5) PDT" for hour in hoursofday]

yearperiods = sort!(collect(distinct(combined.yearperiod)))

fig=Figure()

ax=Axis(fig[1,1], title="May and June $varname at KNZY and KSAN by every 5 years",
        xlabel="Year", ylabel="$varname")

for (hour, hourname) in zip(hoursofday, hournames), airport in airports
    data=combined[combined.hoursofday.==hour, :]
    time=data[:, :yearperiod].+2
    coverfrac=data[:, airport*var]
    lines!(ax, time, coverfrac ; label=airport*" "*hourname)
    scatter!(ax, time, coverfrac)
end

idxer=1:2:length(yearperiods)

yearvalues = collect(yearperiods)[idxer]

ax.xticks = yearvalues

Legend(fig[1,2], ax)

display(fig)

