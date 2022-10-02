for i=1:13
    for j=1:13
        if i>j || i<j
            zMatrix(i,j)=(zMatrix(i,i)+zMatrix(j,j))/2
        end
    end
end