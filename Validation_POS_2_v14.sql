SELECT c.bec_name,c.customer_planning_group,c.fiscal_week,MAX(c.weekid) AS MAX_CURRENT_WEEKID,c.weekid,b.weekid AS CURRENT_WEEKID,c.sum_quantity, b.weekid-c.weekid AS WEEK_GAP,
    SUM(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING) AS SUM_quantity_bec_name,
    AVG(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid ROWS BETWEEN 13 PRECEDING AND 1 PRECEDING) AS AVG_quantity_bec_name,
    STDDEV(c.sum_quantity)OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) AS STDDEV_quantity_bec_name,
    STDDEV(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) +
    AVG(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) AS Upper_Range_1,
    AVG(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) -
    STDDEV(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) AS Lower_Range_1,
        CASE WHEN c.sum_quantity BETWEEN AVG(c.sum_quantity) OVER(PARTITION BY c.bec_name, c.customer_planning_group ORDER BY b.weekid-c.weekid) -
            STDDEV(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid)
            AND 
            STDDEV(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) +
            AVG(c.sum_quantity) OVER(PARTITION BY c.bec_name,c.customer_planning_group ORDER BY b.weekid-c.weekid) THEN 'Correct'
            ELSE 'Exceeds standard deviation'
            END AS Status
FROM
(SELECT bec_name,customer_planning_group,weekid,fiscal_week,SUM(quantity) AS sum_quantity
FROM DCBM.V_POS_P4
WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR0' AND bec_name='AIR'
GROUP BY bec_name,customer_planning_group,weekid,fiscal_week
UNION
SELECT bec_name,customer_planning_group,weekid,fiscal_week,SUM(quantity) AS sum_quantity
FROM DCBM.V_POS_P4
WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR-1' AND bec_name='AIR'
GROUP BY bec_name,customer_planning_group,weekid,fiscal_week
UNION
SELECT bec_name,customer_planning_group,weekid,fiscal_week,SUM(quantity) AS sum_quantity
FROM DCBM.V_POS_P4
WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR-2' AND bec_name='AIR'
GROUP BY bec_name,customer_planning_group,weekid,fiscal_week)c
LEFT JOIN (SELECT WEEKID FROM DCBM.v_fiscal_date WHERE to_char(SYSDATE-7,'MM/DD/YYYY')=to_char(date_value,'MM/DD/YYYY'))b ON 1=1
WHERE b.weekid-c.weekid=0
GROUP BY  c.bec_name,c.customer_planning_group,c.fiscal_week,c.weekid,b.weekid, b.weekid-c.weekid,c.sum_quantity
ORDER BY c.bec_name,c.customer_planning_group,b.weekid,c.fiscal_week