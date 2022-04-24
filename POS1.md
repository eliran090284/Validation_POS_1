# Validation_POS_1
Validation_POS_1_Looking_Nulls
SELECT b.BEC_NAME,b.customer_planning_group, a.MAX_F_W_Q_DESC,c.QUANTITY,e.WEEKID,d.sum_quantity
FROM
(SELECT MAX("f_w_q_desc")MAX_F_W_Q_DESC FROM dcbm.v_fiscal_date_P
WHERE SYSDATE-7 >=date_value AND internal_quarter_code='QTR0' AND day_name='Wednesday' AND "f_w_q_desc" IN ('WEEK 01','WEEK 02','WEEK 03','WEEK 04','WEEK 05','WEEK 06','WEEK 07','WEEK 08','WEEK 09','WEEK 10','WEEK 11')
UNION
SELECT MAX("f_w_q_desc") AS MAX_F_W_Q_DESC FROM dcbm.v_fiscal_date_P
WHERE SYSDATE-7 >=date_value AND internal_quarter_code='QTR-1' AND day_name='Wednesday' AND "f_w_q_desc" IN ('WEEK 12','WEEK 13')) a
INNER JOIN (SELECT DISTINCT BEC_NAME,customer_planning_group FROM DCBM.V_POS_P4 WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND(internal_quarter_code= 'QTR0' OR internal_quarter_code= 'QTR-1')) b ON (1=1)
LEFT JOIN (SELECT bec_name,MAX(fiscal_week) AS MAX_FISCAL_WEEK,customer_planning_group,SUM(quantity) AS QUANTITY
FROM DCBM.V_POS_P4
WHERE FISCAL_WEEK IN ('WEEK 12','WEEK 13') AND LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR-1' 
GROUP BY bec_name,customer_planning_group
UNION
SELECT bec_name,MAX(fiscal_week) AS MAX_FISCAL_WEEK,customer_planning_group,SUM(quantity) AS QUANTITY
FROM DCBM.V_POS_P4
WHERE FISCAL_WEEK IN ('WEEK 01','WEEK 02','WEEK 03','WEEK 04','WEEK 05','WEEK 06','WEEK 07','WEEK 08','WEEK 09','WEEK 10','WEEK 11') AND LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR0' 
GROUP BY bec_name,customer_planning_group)c ON c.bec_name=b.bec_name AND c.MAX_FISCAL_WEEK=a.MAX_F_W_Q_DESC
/*ADD SUM QUA*/
LEFT JOIN (SELECT bec_name,customer_planning_group,weekid,fiscal_week,SUM(quantity) AS sum_quantity
FROM DCBM.V_POS_P4
WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR0' 
GROUP BY bec_name,customer_planning_group,weekid,fiscal_week
UNION ALL
SELECT bec_name,customer_planning_group,weekid,fiscal_week,SUM(quantity) AS sum_quantity
FROM DCBM.V_POS_P4
WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR-1' 
GROUP BY bec_name,customer_planning_group,weekid,fiscal_week
UNION
SELECT bec_name,customer_planning_group,weekid,fiscal_week,SUM(quantity) AS sum_quantity
FROM DCBM.V_POS_P4
WHERE LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR-2' 
GROUP BY bec_name,customer_planning_group,weekid,fiscal_week) d ON d.bec_name=b.bec_name
LEFT JOIN (SELECT WEEKID FROM DCBM.v_fiscal_date WHERE to_char(SYSDATE-7,'MM/DD/YYYY')=to_char(date_value,'MM/DD/YYYY'))e ON 1=1
WHERE C.QUANTITY IS NULL AND a.MAX_F_W_Q_DESC IS NOT NULL
ORDER BY b.BEC_NAME,a.MAX_F_W_Q_DESC
