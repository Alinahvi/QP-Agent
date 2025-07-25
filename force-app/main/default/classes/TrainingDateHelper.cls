/**
 * @description Provides utility methods for parsing relative date terms into concrete date ranges.
 * @author (Your Name/Team)
 * @date (Current Date)
 */
public with sharing class TrainingDateHelper {

    /**
     * @description A simple inner class to hold a start and end date.
     */
    public class DateRange {
        public Date startDate;
        public Date endDate;
    }

    /**
     * @description Parses a standardized, upper-snake-case date term into a DateRange object.
     * @param relativeTerm An upper-snake-case term like 'THIS_WEEK' or 'NEXT_MONTH'.
     * @return DateRange The calculated start and end dates.
     */
    public static DateRange parseRelativeDateTerm(String relativeTerm) {
        DateRange dr = new DateRange();
        if (String.isBlank(relativeTerm)) {
            return null;
        }

        relativeTerm = relativeTerm.toUpperCase().trim();
        Date today = Date.today();

        switch on relativeTerm {
            when 'TODAY' {
                dr.startDate = today;
                dr.endDate = today;
            }
            when 'THIS_WEEK' {
                dr.startDate = today.toStartOfWeek();
                dr.endDate = dr.startDate.addDays(6);
            }
            when 'LAST_WEEK' {
                Date startOfThisWeek = today.toStartOfWeek();
                dr.endDate = startOfThisWeek.addDays(-1);
                dr.startDate = dr.endDate.addDays(-6);
            }
            when 'NEXT_WEEK' {
                Date startOfThisWeek = today.toStartOfWeek();
                dr.startDate = startOfThisWeek.addDays(7);
                dr.endDate = dr.startDate.addDays(6);
            }
            when 'THIS_MONTH' {
                dr.startDate = today.toStartOfMonth();
                dr.endDate = Date.newInstance(today.year(), today.month(), Date.daysInMonth(today.year(), today.month()));
            }
            when 'LAST_MONTH' {
                Date firstDayOfLastMonth = today.toStartOfMonth().addMonths(-1);
                dr.startDate = firstDayOfLastMonth;
                dr.endDate = Date.newInstance(firstDayOfLastMonth.year(), firstDayOfLastMonth.month(), Date.daysInMonth(firstDayOfLastMonth.year(), firstDayOfLastMonth.month()));
            }
            when 'THIS_QUARTER' {
                Integer currentMonth = today.month();
                Integer quarterStartMonth;
                if (currentMonth <= 3) quarterStartMonth = 1;
                else if (currentMonth <= 6) quarterStartMonth = 4;
                else if (currentMonth <= 9) quarterStartMonth = 7;
                else quarterStartMonth = 10;
                
                dr.startDate = Date.newInstance(today.year(), quarterStartMonth, 1);
                Date startOfNextQuarter = dr.startDate.addMonths(3);
                dr.endDate = startOfNextQuarter.addDays(-1);
            }
            when else {
                return null;
            }
        }
        return dr;
    }
}