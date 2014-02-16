# Stock Cutting Problem

# Products
set PRODUCTS;
param pLength{PRODUCTS};
param demand{PRODUCTS};

# Raw Materials
set RAWMATERIALS;
param rLength{RAWMATERIALS};
param avail{RAWMATERIALS};

# Big M should be greater than the length of any stock piece
param bigM;
check {r in RAWMATERIALS} : bigM > rLength[r];

# Create indexed sets enumerating all raw material pieces
set S{r in RAWMATERIALS} := 1..avail[r];

# x[p,r,s] number of product p assigned to (raw material r, piece s)
var x{p in PRODUCTS, r in RAWMATERIALS, s in S[r]} >= 0, integer;

# u[r,s] = 1 indicates use of (raw material r, piece s)
var u{r in RAWMATERIALS, s in S[r]} binary;

# Cut enough pieces to meet the demand for each product
s.t. A{p in PRODUCTS}: sum{r in RAWMATERIALS, s in S[r]} x[p,r,s] = demand[p];

# Do not exceed the length each piece of raw material
s.t. B{r in RAWMATERIALS, s in S[r]} : 
    sum{p in PRODUCTS} pLength[p]*x[p,r,s] <= rLength[r];
    
# Determine if a piece (r,s) of raw material is used.
s.t. C{r in RAWMATERIALS, s in S[r]} : bigM*u[r,s] >= sum{p in PRODUCTS} x[p,r,s];

#minimize Pieces : sum{r in RAWMATERIALS, s in S[r]} rLength[r]*s*u[r,s];

solve;

# w[r,s] is the remainder left over from (raw material r, piece s)
param w{r in RAWMATERIALS, s in S[r]} := rLength[r] - sum{p in PRODUCTS} pLength[p]*x[p,r,s];

table products {p in PRODUCTS} OUT "JSON" "Products" "Table" : 
    p~Product, pLength[p]~Length, demand[p]~Demand;

table rawmaterials {r in RAWMATERIALS} OUT "JSON" "Raw Materials" "Table" : 
    r~Raw_Materials, rLength[r]~Length, avail[r]~Available;

printf "Cutting Plan\n";
for {r in RAWMATERIALS} : {
    printf "    Raw Material %s \n", r;
    for {s in S[r]} : {
        printf "        %4s-%2d: Remainder = %5.2f : Cut ", r,s, w[r,s];
        for {p in PRODUCTS : x[p,r,s] > 0} : {
                printf "%4s(x%2d) ", p, x[p,r,s];
        }
        printf "\n";
    }
    printf "\n";
}

data;

param bigM := 300;

param : PRODUCTS : pLength demand :=
    'P0378'   3.78   16
    'P0408'   4.08    8
    'P0878'   8.78    5
    'P1549'  15.49    8
    'P1642'  16.42    8
    'P2153'  21.53    8
    'P3116'  31.16    4
    'P3226'  32.26    4
    'P4839'  48.39    1
    'P5500'  55.00    8
    'P7298'  72.98    8
 
param : RAWMATERIALS : rLength avail :=
    '280m'  280      13 ;

end;
