Predicting cash flows using generalized additive models
================
Daniel Saxton

Outline
-------

-   Problem description
-   Probabilistic model
-   Generalized additive models
-   R code

Problem
-------

Given information on a customer and the terms of a loan, determine how much cash we expect to collect from this customer.

-   Loan amount
-   Loan term
-   Payment amount
-   Covariate values

Two key behaviors
-----------------

-   Default
-   Prepayment

Both of these are highly dependent on where a customer is in the loan life cycle.

Probabilistic model
-------------------

Associate with each loan two independent processes

-   *T*<sub>*d*</sub>: time until default
-   *T*<sub>*p*</sub>: time until prepayment

Probabilistic model
-------------------

Whether a loan with term *n* is defaulted, prepaid or paid at term corresponds to these events

-   *T*<sub>*d*</sub> &gt; *n*, *T*<sub>*p*</sub> &gt; *n*: loan is paid at term
-   *T*<sub>*d*</sub> ≤ *n*, *T*<sub>*d*</sub> ≤ *T*<sub>*p*</sub>: loan is defaulted
-   *T*<sub>*p*</sub> ≤ *n*, *T*<sub>*p*</sub> &lt; *T*<sub>*d*</sub>: loan is prepaid

In words, which of *T*<sub>*d*</sub>, *T*<sub>*p*</sub> or *n* is the smallest determines the outcome of the loan, with *T*<sub>*d*</sub> winning ties.

Expected cash
-------------

If *X* is the total collected on a given loan and *Y*<sub>*i*</sub> the amount collected at installment *i*

$\\text{E}(X) = \\sum\_{i=1}^{n} \\text{E}(Y\_i)$

Expected cash
-------------

Also if *c* is the regularly-scheduled payment amount and *c*<sub>*i*</sub> the payment amount plus remaining principal at time *i* then

E(*Y*<sub>*i*</sub>)=*c**P*(*T*<sub>*d*</sub> &gt; *i*)*P*(*T*<sub>*p*</sub> &gt; *i*)+*c*<sub>*i*</sub>*P*(*T*<sub>*d*</sub> &gt; *i*)*P*(*T*<sub>*p*</sub> = *i*).

Hazard function
---------------

For a positive integer-valued event time *T* define the hazard function for *k* ∈ ℕ<sub>+</sub>

*h*(*k*)=*P*(*T* = *k* ∣ *T* ≥ *k*).

We also have the nice relationship

$$\\begin{align}
P(T &gt; k) &= \\prod\_{j=1}^{k} \\left \[ 1 - h(j) \\right \] .
\\end{align}
$$
 \#\# Hazard function

-   The hazard function is a probability and so can be modeled using any probabilistic classifier

-   The key is to properly format the data and treat the argument of the hazard function as a covariate

Sample data
-----------

    ##      event install_num term payment amount x
    ## 1  default           1    5     300   1000 5
    ## 2   prepay           3   15     200   2000 7
    ## 3  default           2    3     200    500 3
    ## 4 full_pay           4    4     300   1500 2

After formatting:

    ##    install_num term payment amount x default prepay
    ## 1            1    5     300   1000 5       1      0
    ## 2            1   15     200   2000 7       0      0
    ## 3            2   15     200   2000 7       0      0
    ## 4            3   15     200   2000 7       0      1
    ## 5            1    3     200    500 3       0      0
    ## 6            2    3     200    500 3       1      0
    ## 7            1    4     300   1500 2       0      0
    ## 8            2    4     300   1500 2       0      0
    ## 9            3    4     300   1500 2       0      0
    ## 10           4    4     300   1500 2       0      0

Generalized additive models
---------------------------

Let *μ*<sub>*i*</sub> ∈ *Θ* be the mean of *y*<sub>*i*</sub>, *g* : *Θ* ↦ ℝ a link function and {*x*<sub>*i**j*</sub>}<sub>*j* = 1</sub><sup>*p*</sup> a set of covariate values.

$$ 
g(\\mu\_i) = s\_0 + \\sum\_{j=1}^{p} s(x\_{ij}) 
$$

where the {*s*<sub>*j*</sub>}<sub>*j* = 1</sub><sup>*p*</sup> are smooth functions and *s*<sub>0</sub> a constant.

Advantages
----------

-   Less restrictive than GLMs, can model non-linearities
-   Easy to interpret
-   Useful as an exploratory tool, e.g., finding transformations

Disadvantages
-------------

-   More prone to overfit compared to linear models
-   Implementation is more challenging

Additive models in R
--------------------

-   `gam` (Trevor Hastie)
-   `mgcv` (Simon Wood)

Example
-------

*y*<sub>*i*</sub> = log(*x*<sub>*i*</sub>)+*ϵ*<sub>*i*</sub>

<img src="Saxton,_Daniel_Analyzing_Cash_Flows_using_General_Additive_Models_files/figure-markdown_github/unnamed-chunk-3-1.png" style="display: block; margin: auto;" />

Smooth fit
----------

``` r
model = gam(y ~ s(x), data=data_set)
plot(model)
```

<img src="Saxton,_Daniel_Analyzing_Cash_Flows_using_General_Additive_Models_files/figure-markdown_github/unnamed-chunk-4-1.png" style="display: block; margin: auto;" />

Smooth fit
----------

``` r
model = gam(y ~ s(x, df=2), data=data_set)
plot(model)
```

<img src="Saxton,_Daniel_Analyzing_Cash_Flows_using_General_Additive_Models_files/figure-markdown_github/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

Example
-------

*y*<sub>*i*</sub> = *x*<sub>*i*</sub><sup>2</sup> + *ϵ*<sub>*i*</sub>

<img src="Saxton,_Daniel_Analyzing_Cash_Flows_using_General_Additive_Models_files/figure-markdown_github/unnamed-chunk-6-1.png" style="display: block; margin: auto;" />

Smooth fit
----------

``` r
model = gam(y ~ s(x), data=data_set)
plot(model)
```

<img src="Saxton,_Daniel_Analyzing_Cash_Flows_using_General_Additive_Models_files/figure-markdown_github/unnamed-chunk-7-1.png" style="display: block; margin: auto;" />

Additive logistic regression
----------------------------

For data of the form {*y*<sub>*i*</sub>, *x*<sub>*i*1</sub>, …, *x*<sub>*i**p*</sub>}<sub>*i* = 1</sub><sup>*n*</sup> where *y*<sub>*i*</sub>∼ Bernoulli(*p*<sub>*i*</sub>).

$$
\\log \\left ( \\frac{p\_i}{1 - p\_i} \\right ) = s\_0 + \\sum\_{j=1}^{p} s\_j(x\_{ij})
$$

Additive hazard model
---------------------

    ##    install_num term payment amount x default prepay
    ## 1            1    5     300   1000 5       1      0
    ## 2            1   15     200   2000 7       0      0
    ## 3            2   15     200   2000 7       0      0
    ## 4            3   15     200   2000 7       0      1
    ## 5            1    3     200    500 3       0      0
    ## 6            2    3     200    500 3       1      0
    ## 7            1    4     300   1500 2       0      0
    ## 8            2    4     300   1500 2       0      0
    ## 9            3    4     300   1500 2       0      0
    ## 10           4    4     300   1500 2       0      0

``` r
default_model = gam(default ~ s(install_num) + s(x),
                    data=df,
                    family='binomial')

prepay_model = gam(prepay ~ s(install_num) + s(x),
                   data=df,
                   family='binomial')
```

Survival functions
------------------

``` r
score_function = function(x, loan_term, default_model, prepay_model) {
    # initialize data frame to be scored
    x = data.frame(x)
    x = x[rep(1, loan_term),]
    x$install_num = 1:loan_term
    rownames(x) = NULL
    
    # calculate complement of hazard function by installment
    def_scr = predict(default_model, newdata=x)
    prepay_scr = predict(prepay_model, newdata=x)
    def_scr = 1 / (exp(def_scr) + 1)
    prepay_scr = 1 / (exp(prepay_scr) + 1)
    
    # calculate default and prepayment curves
    surv_func = data.frame(default_curve = cumprod(def_scr),
                           prepay_curve = cumprod(prepay_scr))
    
    return(surv_func)
}
```

Amortization schedule
---------------------

We also need to know the remaining principal at each installment and so have to compute a loan's amortization schedule. For this we have to determine the (implicit) interest rate of the loan.

For a loan with loan amount *A*, payment amount *c* and loan term *n*, the interest rate *r* is the solution to the equation

$$
\\frac{A}{\\sum\_{i=1}^{n} (1 + r)^{-i}} - c = 0 .
$$

Interest calculation
--------------------

``` r
library(nleqslv)

get_interest = function(loan_term, loan_amount, payment_amount) {
    nleqslv(x=1,
            fn=function(x) {
                loan_amount / sum((1 + x)^(-(1:loan_term))) - payment_amount
                })$x
}
```

Amortization schedule
---------------------

``` r
amortize = function(loan_term, loan_amount, payment_amount) {
    # initialize amortization schedule data frame and calculate interest
    schedule = data.frame(payment = rep(payment_amount, loan_term),
                          principal_payment = rep(0, loan_term),
                          interest_payment = rep(0, loan_term),
                          remaining_principal = rep(0, loan_term))
    rate = get_interest(loan_term, loan_amount, payment_amount)
    interest = loan_amount * rate
    
    # iteratively populate and return schedule
    schedule[1, 'interest_payment'] = interest
    schedule[1, 'principal_payment'] = payment_amount - interest
    schedule[1, 'remaining_principal'] = loan_amount - schedule[1, 'principal_payment']
    
    for (i in 2:loan_term) {
        schedule[i, 'interest_payment'] =  schedule[i - 1, 'remaining_principal'] * rate
        schedule[i, 'principal_payment'] =  payment_amount - schedule[i, 'interest_payment']
        schedule[i, 'remaining_principal'] =  schedule[i - 1, 'remaining_principal'] - 
            schedule[i, 'principal_payment']
    }
    return(schedule)
}
```

Amortization schedule
---------------------

``` r
amortize(10, 1000, 120)
```

    ##    payment principal_payment interest_payment remaining_principal
    ## 1      120          85.39846        34.601538        9.146015e+02
    ## 2      120          88.35338        31.646620        8.262482e+02
    ## 3      120          91.41054        28.589457        7.348376e+02
    ## 4      120          94.57349        25.426512        6.402641e+02
    ## 5      120          97.84588        22.154124        5.424183e+02
    ## 6      120         101.23149        18.768506        4.411868e+02
    ## 7      120         104.73426        15.265740        3.364525e+02
    ## 8      120         108.35823        11.641774        2.280943e+02
    ## 9      120         112.10759         7.892413        1.159867e+02
    ## 10     120         115.98668         4.013318        7.404091e-08

Putting it all together
-----------------------

``` r
compute_cash_flow(x,
                  loan_term,
                  loan_amount,
                  payment_amount,
                  default_model,
                  prepay_model,
                  j=0)
```

This returns a list that contains the amortization schedule, estimated default and prepayment curves, expected cash flow by installment, as well as the total expected cash. The extra parameter `j` allows for making updated projections.

Updating the projections
------------------------

Given that a loan is current at time *j* then for *i* &gt; *j*

$$
\\text{E}(Y\_i) = c \\frac{P(T\_d &gt; i)}{P(T\_d &gt; j)} \\frac{P(T\_p &gt; i)}{P(T\_p &gt; j)} + c\_i \\frac{P(T\_d &gt; i)}{P(T\_d &gt; j)} \\frac{P(T\_p = i)}{P(T\_p &gt; j)} .
$$

The additional cash expected can be found by summing over *i* ∈ {*j* + 1, …, *n*}.

References
----------

-   Hastie, T., Tibshirani, R. "Generalized Additive Models." *Statistical Science*. Vol. 1, No. 3, 1986, pg. 297-318.

-   Allison, P. "Discrete-Time Methods for the Analysis of Event Histories." *Sociological Methodology*. Vol. 13, 1982, pg. 61-98.
