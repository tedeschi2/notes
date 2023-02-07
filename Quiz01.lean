
Quiz 1 

inductive Weekday (day : String) where
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday

def Weekday.odds : Weekday → String

#print Weekday