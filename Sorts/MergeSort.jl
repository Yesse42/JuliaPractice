"Merges from the work array into the array A"
function merge!(A,workarr,beginidx,middleidx,endidx)
    array1_idx=beginidx
    array2_idx=middleidx+1
    for i in beginidx:endidx
        if array1_idx<=middleidx && (array2_idx>endidx || workarr[array1_idx]<workarr[array2_idx])
            A[i]=workarr[array1_idx]
            array1_idx+=1
        else
            A[i]=workarr[array2_idx]
            array2_idx+=1
        end
    end
end

"Split the array in half, and then copy them over to B"
function recursive_merge_sort!(data_arr,work_arr)
    idxbegin=first(LinearIndices(data_arr))
    idxend=last(LinearIndices(data_arr))
    if (idxbegin==idxend) return end
    #Get the index to split the array on
    idxmiddle=fld(idxbegin+idxend,2)
    #Then split the array, merge sorting the upper and lower halves
    #Use views for performance reasons
    recursive_merge_sort!(@views(work_arr[begin:idxmiddle]),@views(data_arr[begin:idxmiddle]))
    recursive_merge_sort!(@views(work_arr[idxmiddle+1:end]),@views(data_arr[idxmiddle+1:end]))
    #And now perform the actual merge after the arrays have been sorted
    merge!(data_arr,work_arr,idxbegin,idxmiddle,idxend)
end

function merge_sort!(A)
    workarr=copy(A)
    recursive_merge_sort!(A,workarr)
end

B=collect(8:-1:1)
display(B)
merge_sort!(B)
display(B)