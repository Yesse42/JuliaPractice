module GaussianElim

import Base.Iterators as Itr

export RREF, RREF!

function RREF!(A)
    T = eltype(A)
    rows, cols = axes(A)
    current_col, maxcol = extrema(cols)
    current_row, maxrow = extrema(rows)
    while(current_row<=maxrow && current_col<=maxcol)
        #Move the row with the largest value in the current column up to the current row
        row_with_val = argmax(map(abs, @view(A[current_row:end, current_col])))
        row_with_val = row_with_val + current_row -1
        #If the max is 0 set the column to 0 and move on
        if isapprox(A[row_with_val, current_col], 0; atol=1e-10) 
            A[current_row:end, current_col] .= 0 
            current_col+=1
            continue
        end
        A[current_row,:], A[row_with_val, :] = A[row_with_val, :], A[current_row, :]

        #Make the value in the current column equal to 1 by scaling
        A[current_row,:] ./= A[current_row, current_col]

        #Now that this row has a 1 in the current column, make every other value in its column zero with scaling and subtraction
        for rowidx in rows
            rowidx==current_row && continue
            A[rowidx, :] .-= @view(A[current_row, :]) .* A[rowidx, current_col]
        end

        #And now move into the next row and next column
        current_row+=1
        current_col+=1
    end

    return A
end

function RREF(A)
    T = eltype(A)
    if T <: Integer
        RREF!(A.//one(T))
    else
        RREF!(deepcopy(A))
    end
end

end # module
