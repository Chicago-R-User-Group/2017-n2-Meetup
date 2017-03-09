

library(gam)

## Sample Data
data = data.frame(event = c('default', 'prepay', 'default', 'full_pay'),
                  install_num = c(1, 3, 2, 4),
                  term = c(5, 15, 3, 4),
                  payment = c(300, 200, 200, 300),
                  amount = c(1000, 2000, 500, 1500),
                  x = rpois(4, lambda=6))

data

## Formatting

expanded = data[c(rep(1, 1), rep(2, 3), rep(3, 2), rep(4, 4)),]
expanded$install_num = c(1:1, 1:3, 1:2, 1:4)
expanded$default = c(1, rep(0, 4), 1, rep(0, 4))
expanded$prepay = c(rep(0, 3), 1, rep(0, 6))
expanded$event = NULL
rownames(expanded) = NULL
expanded
##
x = rexp(100)
y = log(x) + rnorm(100)
data_set = data.frame(x, y)
plot(data_set$x, data_set$y, xlab='x', ylab='y')

## Smooth fit
model = gam(y ~ s(x), data=data_set)
plot(model)

## Smooth fit
model = gam(y ~ s(x, df=2), data=data_set)
plot(model)

## Example
x = rexp(100)
y = x^2 + rnorm(100)
data_set = data.frame(x, y)
plot(data_set$x, data_set$y, xlab='x', ylab='y')


## Smooth fit
model = gam(y ~ s(x), data=data_set)
plot(model)
##
expanded

## Additive hazard model
default_model = gam(default ~ s(install_num) + s(x),
                    data=df,
                    family='binomial')

prepay_model = gam(prepay ~ s(install_num) + s(x),
                   data=df,
                   family='binomial')

## Survival functions
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

## Interest calculation
library(nleqslv)
get_interest = function(loan_term, loan_amount, payment_amount) {
        nleqslv(x=1,
                fn=function(x) {
                        loan_amount / sum((1 + x)^(-(1:loan_term))) - payment_amount
                })$x

}
## Amortization schedule
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

## Amortization schedule

amortize(10, 1000, 120)

## Putting it all together
compute_cash_flow(x,
                  loan_term,
                  loan_amount,
                  payment_amount,
                  default_model,
                  prepay_model,
                  j=0)
