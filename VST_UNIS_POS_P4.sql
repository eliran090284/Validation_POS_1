SELECT bec_name,customer_name,customer_planning_group,SUM(QUANTITY) AS SUM_QUANTITY,fiscal_week 
FROM DCBM.V_POS_P4
WHERE BEC_NAME= 'VST CN USD' AND LEGACY_SUB='LW' AND cpg_type='Distribution' AND bu_line_name='Devices' AND INTERNAL_QUARTER_CODE='QTR0'
GROUP BY bec_name,customer_name,customer_planning_group,fiscal_week 