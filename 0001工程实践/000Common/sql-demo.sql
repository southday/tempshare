/*
��ѯ������
  branch �ֹ�˾
  year   ���
  month  �·�
  region ����
  zone   ���� 
*/

-- ���ָ�� == [�����ָ�ꡱ�����¶��ۼ�ָ�ꡱ���ɡ��¶ȷֽ�ָ�굼�롱��Ϣ��ȷ����]
SELECT mtv.year_total
  FROM inst_gov_exam_month_target_v mtv
 WHERE mtv.year = 2016
   AND mtv.branch = '�����ֹ�˾';

-- �������̨�� == [���������̨�������Զ����㣬��ֵ����������ͳ�����ڴӵ��굱��1�յ������µ׵�̨���ܺ͡�]
SELECT gemt.branch,
  FROM inst_gov_exam_ele gee,
       inst_ele ie,
       inst_az_contract iac,
       inst_gov_exam_month_target gemt
 WHERE gemt.branch = iac.inst_branch(+)
   AND iac.az_vbeln = ie.matnr(+)
   AND ie.matnr = gee.ele_contract_no(+)
   AND gemt.year = 2016
   AND gee.gov_exam_stat_date >= TRUNC(gee.gov_exam_stat_date, 'mm')
   AND gee.gov_exam_stat_date <= TRUNC(last_day(gee.gov_exam_stat_date), 'dd')
 GROUP BY gemt.branch;

SELECT gemt.branch,
       iac.az_vbeln
  FROM inst_gov_exam_month_target gemt,
       inst_az_contract iac
 WHERE gemt.branch = iac.inst_branch(+)
   AND gemt.year = 2016
 GROUP BY gemt.branch, iac.az_vbeln;

-- 6332
SELECT COUNT(1)
       -- DISTINCT iac.inst_branch
       /*gee.exam_ele_id,
       gee.ele_contract_no,
       gee.doc_status,
       gee.doc_level,
       gee.gov_exam_stat_date,
       iac.inst_branch,
       gee.lastupdate_date*/
  FROM inst_gov_exam_ele gee,
       inst_ele ie,
       inst_az_contract iac
 WHERE gee.ele_contract_no = ie.matnr
   AND ie.az_vbeln = iac.az_vbeln(+)
   AND (gee.doc_status = 'APPROVED' OR
        gee.doc_status = 'COMPLETED');

-- 6371 (right)
/*
��ͷ�ֹ�˾
���ݷֹ�˾
...
*/
SELECT mtv.branch,
       mtv.year,
       mtv.month_dec,
       mtv.month_total,
       mtv.year_total,
       gev.branch gev_branch
  FROM inst_gov_exam_month_target_v mtv,
       (SELECT gee.exam_ele_id,
               gee.ele_contract_no,
               gee.doc_status,
               gee.doc_level,
               gee.gov_exam_stat_date,
               iac.inst_branch branch,
               gee.lastupdate_date
          FROM inst_gov_exam_ele gee,
               inst_ele ie,
               inst_az_contract iac
         WHERE gee.ele_contract_no = ie.matnr
           AND ie.az_vbeln = iac.az_vbeln(+)
           AND gee.gov_exam_stat_date >= TRUNC(SYSDATE, 'year')
           AND gee.gov_exam_stat_date <= TRUNC(last_day(SYSDATE), 'dd')) gev
 WHERE mtv.branch = gev.branch(+)
   AND mtv.year = 2016;

-- ȱʧ SMEC�ܹ�˾
SELECT COUNT(1)
  FROM inst_gov_exam_month_target_v mtv
 WHERE mtv.year = 2016;

SELECT DISTINCT iac.inst_branch
  FROM inst_gov_exam_ele gee,
       inst_ele ie,
       inst_az_contract iac
 WHERE gee.ele_contract_no = ie.matnr
   AND ie.az_vbeln = iac.az_vbeln(+);

SELECT * FROM inst_az_contract iac
WHERE iac.inst_branch = 'SMEC�ܹ�˾';

SELECT mtv.target_id,
       mtv.branch,
       mtv.year,
       mtv.month,
       mtv.month_dec,
       mtv.month_total,
       mtv.year_total,
       gev.gov_exam_stat_date,
       gev.doc_status,
       gev.doc_level,
       gev.lastupdate_date
  FROM inst_gov_exam_month_target_v mtv,
       (SELECT gee.ele_contract_no,
               gee.doc_status,
               gee.doc_level,
               gee.gov_exam_stat_date,
               iac.inst_branch branch,
               gee.lastupdate_date
          FROM inst_gov_exam_ele gee,
               inst_ele ie,
               inst_az_contract iac
         WHERE gee.ele_contract_no = ie.matnr
           AND ie.az_vbeln = iac.az_vbeln(+)) gev
 WHERE mtv.branch = gev.branch(+)
   AND gev.doc_status = 'COMPLETED'
   AND gev.doc_level = 'INST_PLANNER';


-- �������̨�� == [���������̨�������Զ����㣬��ֵ����������ͳ�����ڴӵ��굱��1�յ������µ׵�̨���ܺ͡�
SELECT mtv.branch,
       COUNT(1) mon_cmpl -- �������̨��
  FROM inst_gov_exam_month_target_v mtv,
       (SELECT gee.exam_ele_id,
               gee.ele_contract_no,
               gee.doc_status,
               gee.doc_level,
               gee.gov_exam_stat_date,
               iac.inst_branch branch,
               gee.lastupdate_date
          FROM inst_gov_exam_ele gee,
               inst_ele ie,
               inst_az_contract iac
         WHERE gee.ele_contract_no = ie.matnr
           AND ie.az_vbeln = iac.az_vbeln(+)) gev
 WHERE mtv.branch = gev.branch(+)
   AND mtv.year = 2017
   AND inst_gov_exam_view_pkg.set_month(1) = 1
   AND gev.gov_exam_stat_date >= TRUNC(to_date('2017-01', 'yyyy-MM'), 'mm') -- �����������ڴ��ڵ��� 2016��3��1��
   AND gev.gov_exam_stat_date <= TRUNC(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2016��3�����һ��
 GROUP BY mtv.branch;

-- �����ָ�ꡱ�����¶��ۼ�ָ�ꡱ���ɡ��¶ȷֽ�ָ�굼�롱��Ϣ��ȷ���� [y]
-- ���¶��ۼ����̨�������Զ����㣬��ֵ����������ͳ�����ڴ�1��1�յ������µ׵�̨���ܺ͡� [y]
-- ���¶��ۼ���ɳ������Զ����㣬��ֵ���¶��ۼ����̨�����¶��ۼ�ָ�ꡣ [y]
-- ���¶�ָ������ʡ����Զ����㣬��ֵ���¶��ۼ����̨�����¶��ۼ�ָ�ꡣ [y]
-- �����ָ������ʡ����Զ����㣬��ֵ���¶��ۼ����̨�������ָ�ꡣ [y]
SELECT mtv.branch,
       mtv.year_total, -- ���ָ��
       mtv.month_total, -- �¶��ۼ�ָ��
       COUNT(1) mon_cmpl_total, -- ���ۼ����̨��
       (COUNT(1) - mtv.month_total) mon_cmpl_over, -- �¶��ۼ���ɳ����
       ROUND((COUNT(1)/mtv.month_total), 3) mon_cmpl_rate, -- �¶�ָ�������
       ROUND((COUNT(1)/mtv.year_total), 3) year_cmpl_rate -- ���ָ�������
  FROM inst_gov_exam_month_target_v mtv,
       (SELECT gee.exam_ele_id,
               gee.ele_contract_no,
               gee.doc_status,
               gee.doc_level,
               gee.gov_exam_stat_date,
               iac.inst_branch branch,
               gee.lastupdate_date
          FROM inst_gov_exam_ele gee,
               inst_ele ie,
               inst_az_contract iac
         WHERE gee.ele_contract_no = ie.matnr
           AND ie.az_vbeln = iac.az_vbeln(+)) gev
 WHERE mtv.branch = gev.branch(+)
   AND mtv.year = 2017
   AND inst_gov_exam_view_pkg.set_month(1) = 1
   AND gev.gov_exam_stat_date >= TRUNC(to_date('2017-01', 'yyyy-MM'), 'year') -- �����������ڴ��ڵ��� 2017��1��1��
   AND gev.gov_exam_stat_date <= TRUNC(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2017��1�����һ��
 GROUP BY mtv.branch, mtv.month_total, mtv.year_total;

-- ����ǰ����̨�������Զ����㣬��ֵ���ܲ���װ�ƻ�Ա���ҵĴ��족������ڸ÷ֹ�˾������������
SELECT biv.branch,
       COUNT(1) on_task -- ��ǰ����̨��
  FROM inst_gov_exam_brief_info_v biv
 WHERE biv.doc_status = 'APPROVED'
   AND biv.doc_level = 'INST_PLANNER'
   AND biv.lastupdate_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- ����"�ҵĴ���"�ڵ��ʱ�� ���ڵ��� 2017��1��1��
   AND biv.lastupdate_date <=
       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ����"�ҵĴ���"�ڵ��ʱ�� С�ڵ��� 2017��1�����һ��
 GROUP BY biv.branch;

SELECT * FROM inst_gov_exam_brep_p1_v;

SELECT t2.branch, -- �ֹ�˾
       t2.year_total, -- ���ָ��
       t2.month_total, -- �¶��ۼ�ָ��
       t1.mon_cmpl, -- �������̨��
       t2.mon_cmpl_total, -- �¶��ۼ����̨��
       t2.mon_cmpl_over, -- �¶��ۼ���ɳ����
       t2.mon_cmpl_rate, -- �¶��ۼ�ָ�������
       t2.year_cmpl_rate -- ���ָ�������
  FROM (SELECT rv1.branch, COUNT(1) mon_cmpl -- �������̨��
          FROM inst_gov_exam_brep_p1_v rv1
         WHERE rv1.year = 2017
           AND inst_gov_exam_view_pkg.set_month(1) = 1
           AND rv1.gov_exam_stat_date >=
               trunc(to_date('2017-01', 'yyyy-MM'), 'mm') -- �����������ڴ��ڵ��� 2016��3��1��
           AND rv1.gov_exam_stat_date <=
               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2016��3�����һ��
         GROUP BY rv1.branch) t1,
       (SELECT rv2.branch,
               rv2.year_total, -- ���ָ��
               rv2.month_total, -- �¶��ۼ�ָ��
               COUNT(1) mon_cmpl_total, -- ���ۼ����̨��
               (COUNT(1) - rv2.month_total) mon_cmpl_over, -- �¶��ۼ���ɳ����
               round((COUNT(1) / rv2.month_total), 3) mon_cmpl_rate, -- �¶�ָ�������
               round((COUNT(1) / rv2.year_total), 3) year_cmpl_rate -- ���ָ�������
          FROM inst_gov_exam_brep_p1_v rv2
         WHERE rv2.year = 2017
           AND inst_gov_exam_view_pkg.set_month(1) = 1
           AND rv2.gov_exam_stat_date >=
               trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- �����������ڴ��ڵ��� 2017��1��1��
           AND rv2.gov_exam_stat_date <=
               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2017��1�����һ��
         GROUP BY rv2.branch, rv2.month_total, rv2.year_total) t2
 WHERE t1.branch = t2.branch;

---------------------------------------------------------------------------------------------------
-- �汾1�������ڼ���"�������̨��"��ʱ����[pv1.branch = pv2.branch]�����������ܻᶪʧ����

SELECT t1.branch,
       t1.year_total, -- ���ָ��
       t1.month_total, -- �¶��ۼ�ָ��
       nvl(t2.mon_cmpl, 0) mon_cmpl, -- �������̨��
       nvl(t2.mon_cmpl_total, 0) mon_cmpl_total, -- �¶��ۼ����̨��
       nvl(t2.mon_cmpl_over, 0) mon_compl_over, -- �¶��ۼ���ɳ����
       nvl(t2.mon_cmpl_rate, 0) mon_compl_rate, -- �¶��ۼ�ָ�������
       nvl(t2.year_cmpl_rate, 0) year_compl, -- ���ָ�������
       t1.on_task -- ��ǰ����̨��
  FROM (SELECT mtv.target_id,
               mtv.branch,
               mtv.year,
               mtv.month,
               mtv.month_total, -- ���ָ��
               mtv.year_total, -- �¶��ۼ�ָ��
               NVL(otv.on_task, 0) on_task -- ��ǰ����̨��
          FROM inst_gov_exam_month_target_v mtv,
               (SELECT biv.branch,
                       COUNT(1) on_task -- ��ǰ����̨��
                  FROM inst_gov_exam_brief_info_v biv
                 WHERE biv.doc_status = 'APPROVED'
                   AND biv.doc_level = 'INST_PLANNER'
                   AND biv.lastupdate_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- ����"�ҵĴ���"�ڵ��ʱ�� ���ڵ��� 2017��1��1��
                   AND biv.lastupdate_date <=
                       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ����"�ҵĴ���"�ڵ��ʱ�� С�ڵ��� 2017��1�����һ��
                 GROUP BY biv.branch) otv
         WHERE mtv.branch = otv.branch(+)) t1,
       (SELECT pv2.branch, -- �ֹ�˾
               pv2.year_total, -- ���ָ��
               pv2.month_total, -- �¶��ۼ�ָ��
               pv1.mon_cmpl, -- �������̨��
               pv2.mon_cmpl_total, -- �¶��ۼ����̨��
               pv2.mon_cmpl_over, -- �¶��ۼ���ɳ����
               pv2.mon_cmpl_rate, -- �¶��ۼ�ָ�������
               pv2.year_cmpl_rate -- ���ָ�������
          FROM (SELECT rv1.branch, COUNT(1) mon_cmpl -- �������̨��
                  FROM inst_gov_exam_brep_p1_v rv1
                 WHERE rv1.year = 2017
                   AND inst_gov_exam_view_pkg.set_month(1) = 1
                   AND rv1.gov_exam_stat_date >=
                       trunc(to_date('2017-01', 'yyyy-MM'), 'mm') -- �����������ڴ��ڵ��� 2016��3��1��
                   AND rv1.gov_exam_stat_date <=
                       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2016��3�����һ��
                 GROUP BY rv1.branch) pv1,
               (SELECT rv2.branch,
                       rv2.year_total, -- ���ָ��
                       rv2.month_total, -- �¶��ۼ�ָ��
                       COUNT(1) mon_cmpl_total, -- ���ۼ����̨��
                       (COUNT(1) - rv2.month_total) mon_cmpl_over, -- �¶��ۼ���ɳ����
                       round((COUNT(1) / rv2.month_total), 3) mon_cmpl_rate, -- �¶�ָ�������
                       round((COUNT(1) / rv2.year_total), 3) year_cmpl_rate -- ���ָ�������
                  FROM inst_gov_exam_brep_p1_v rv2
                 WHERE rv2.year = 2017
                   AND inst_gov_exam_view_pkg.set_month(1) = 1
                   AND rv2.gov_exam_stat_date >=
                       trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- �����������ڴ��ڵ��� 2017��1��1��
                   AND rv2.gov_exam_stat_date <=
                       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2017��1�����һ��
                 GROUP BY rv2.branch, rv2.month_total, rv2.year_total) pv2
         WHERE pv1.branch = pv2.branch) t2
 WHERE t1.branch = t2.branch(+)
   AND t1.year = 2017;

-----------------------------------------------------------------------------------------------------
-- �汾2����˰汾1���ܻᶪʧ���ݵ�����
SELECT t1.branch,
       t1.year_total, -- ���ָ��
       t1.month_total, -- �¶��ۼ�ָ��
       nvl(t1.mon_cmpl, 0) mon_cmpl, -- �������̨��
       nvl(t2.mon_cmpl_total, 0) mon_cmpl_total, -- �¶��ۼ����̨��
       nvl(t2.mon_cmpl_over, 0) mon_compl_over, -- �¶��ۼ���ɳ����
       nvl(t2.mon_cmpl_rate, 0) mon_compl_rate, -- �¶��ۼ�ָ�������
       nvl(t2.year_cmpl_rate, 0) year_compl, -- ���ָ�������
       t1.on_task -- ��ǰ����̨��
  FROM (SELECT mv1.target_id,
               mv1.branch,
               mv1.year,
               mv1.month,
               mv1.month_total, -- ���ָ��
               mv1.year_total, -- �¶��ۼ�ָ��
               mv1.on_task, -- ��ǰ����̨��
               mv2.mon_cmpl -- �������̨��
          FROM (SELECT mtv.target_id,
                       mtv.branch,
                       mtv.year,
                       mtv.month,
                       mtv.month_total, -- ���ָ��
                       mtv.year_total, -- �¶��ۼ�ָ��
                       NVL(otv.on_task, 0) on_task -- ��ǰ����̨��
                  FROM inst_gov_exam_month_target_v mtv,
                       (SELECT biv1.branch,
                               COUNT(1) on_task -- ��ǰ����̨��
                          FROM inst_gov_exam_brief_info_v biv1
                         WHERE biv1.doc_status = 'APPROVED'
                           AND biv1.doc_level = 'INST_PLANNER'
                           AND biv1.lastupdate_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- ����"�ҵĴ���"�ڵ��ʱ�� ���ڵ��� 2017��1��1��
                           AND biv1.lastupdate_date <=
                               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ����"�ҵĴ���"�ڵ��ʱ�� С�ڵ��� 2017��1�����һ��
                         GROUP BY biv1.branch) otv
                 WHERE mtv.branch = otv.branch(+)
                   AND mtv.year = 2017) mv1,
               (SELECT biv2.branch, COUNT(1) mon_cmpl -- �������̨��
                  FROM inst_gov_exam_brief_info_v biv2
                 WHERE biv2.doc_status = 'COMPLETED'
                   AND biv2.doc_level = 'INST_PLANNER'
                   AND biv2.gov_exam_stat_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'mm') -- �����������ڴ��ڵ��� 2016��3��1��
                   AND biv2.gov_exam_stat_date <= trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2016��3�����һ��
                 GROUP BY biv2.branch) mv2
         WHERE mv1.branch = mv2.branch(+)) t1,
       (SELECT bpv1.branch,
               bpv1.year_total, -- ���ָ��
               bpv1.month_total, -- �¶��ۼ�ָ��
               COUNT(1) mon_cmpl_total, -- ���ۼ����̨��
               (COUNT(1) - bpv1.month_total) mon_cmpl_over, -- �¶��ۼ���ɳ����
               round((COUNT(1) / bpv1.month_total), 3) mon_cmpl_rate, -- �¶�ָ�������
               round((COUNT(1) / bpv1.year_total), 3) year_cmpl_rate -- ���ָ�������
          FROM inst_gov_exam_brep_p1_v bpv1
         WHERE bpv1.year = 2017
           AND inst_gov_exam_view_pkg.set_month(1) = 1
           AND bpv1.gov_exam_stat_date >=
               trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- �����������ڴ��ڵ��� 2017��1��1��
           AND bpv1.gov_exam_stat_date <=
               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- ������������С�ڵ��� 2017��1�����һ��
         GROUP BY bpv1.branch, bpv1.month_total, bpv1.year_total) t2
 WHERE t1.branch = t2.branch(+)
   AND t1.year = 2017;

-----------------------------------------------------------------------------------------------------
-- �汾3: ��ʱ���йصĲ�ѯ����ͨ��set_date_params����ʼ����Ȼ���ڸ���where��ͨ��get��ȡ�������������(ʡ���ֹ�˾)�ʹ���
CREATE OR REPLACE VIEW inst_gov_exam_brep_v AS
SELECT mcv.zone_name, -- ����
       mcv.pr_comp_name, -- ʡ���ֹ�˾
       mt.branch, -- �ֹ�˾
       mt.year_total, -- ���ָ��
       mt.month_total, -- �¶��ۼ�ָ��
       mt.mon_cmpl, -- �������̨��
       mt.mon_cmpl_total, -- �¶��ۼ����̨��
       mt.mon_cmpl_over, -- �¶��ۼ���ɳ����
       mt.mon_cmpl_rate, -- �¶��ۼ�ָ�������
       mt.year_cmpl_rate, -- ���ָ�������
       mt.on_task -- ��ǰ����̨��
  FROM md_company_v mcv,
       (SELECT t1.branch,
               t1.year_total, -- ���ָ��
               t1.month_total, -- �¶��ۼ�ָ��
               nvl(t1.mon_cmpl, 0) mon_cmpl, -- �������̨��
               nvl(t2.mon_cmpl_total, 0) mon_cmpl_total, -- �¶��ۼ����̨��
               nvl(t2.mon_cmpl_over, 0) mon_cmpl_over, -- �¶��ۼ���ɳ����
               nvl(t2.mon_cmpl_rate, 0) mon_cmpl_rate, -- �¶��ۼ�ָ�������
               nvl(t2.year_cmpl_rate, 0) year_cmpl_rate, -- ���ָ�������
               t1.on_task -- ��ǰ����̨��
          FROM (SELECT mv1.branch,
                       mv1.year,
                       mv1.month,
                       mv1.month_total, -- �¶��ۼ�ָ��
                       mv1.year_total, -- ���ָ��
                       mv1.on_task, -- ��ǰ����̨��
                       mv2.mon_cmpl -- �������̨��
                  FROM (SELECT mtv.branch,
                               mtv.year,
                               mtv.month,
                               mtv.month_total, -- �¶��ۼ�ָ��
                               mtv.year_total, -- ���ָ��
                               NVL(otv.on_task, 0) on_task -- ��ǰ����̨��
                          FROM inst_gov_exam_month_target_v mtv,
                               (SELECT biv1.branch,
                                       COUNT(1) on_task -- ��ǰ����̨��
                                  FROM inst_gov_exam_brief_info_v biv1
                                 WHERE biv1.doc_status = 'APPROVED'
                                   AND biv1.doc_level = 'INST_PLANNER'
                                   AND biv1.lastupdate_date >= inst_gov_exam_view_pkg.get_year_fd -- ����"�ҵĴ���"�ڵ��ʱ�� ���ڵ��� y��ĵ�һ��
                                   AND biv1.lastupdate_date <= inst_gov_exam_view_pkg.get_mon_ld -- ����"�ҵĴ���"�ڵ��ʱ�� С�ڵ��� y��m�����һ��
                                 GROUP BY biv1.branch) otv
                         WHERE mtv.branch = otv.branch(+)
                           AND mtv.year = inst_gov_exam_view_pkg.get_year) mv1,
                       (SELECT biv2.branch, COUNT(1) mon_cmpl -- �������̨��
                          FROM inst_gov_exam_brief_info_v biv2
                         WHERE biv2.doc_status = 'COMPLETED'
                           AND biv2.doc_level = 'INST_PLANNER'
                           AND biv2.gov_exam_stat_date >= inst_gov_exam_view_pkg.get_mon_fd -- ��������ͳ�����ڴ��ڵ��� y��m�µĵ�һ��
                           AND biv2.gov_exam_stat_date <= inst_gov_exam_view_pkg.get_mon_ld -- ��������ͳ������С�ڵ��� y��m�����һ��
                         GROUP BY biv2.branch) mv2
                 WHERE mv1.branch = mv2.branch(+)) t1,
               (SELECT bpv1.branch,
                       COUNT(1) mon_cmpl_total, -- ���ۼ����̨��
                       (COUNT(1) - bpv1.month_total) mon_cmpl_over, -- �¶��ۼ���ɳ����
                       round((COUNT(1) / bpv1.month_total), 3) mon_cmpl_rate, -- �¶�ָ�������
                       round((COUNT(1) / bpv1.year_total), 3) year_cmpl_rate -- ���ָ�������
                  FROM inst_gov_exam_brep_p1_v bpv1
                 WHERE bpv1.year = inst_gov_exam_view_pkg.get_year
                   AND bpv1.gov_exam_stat_date >= inst_gov_exam_view_pkg.get_year_fd -- ��������ͳ�����ڴ��ڵ��� y��ĵ�һ��
                   AND bpv1.gov_exam_stat_date <= inst_gov_exam_view_pkg.get_mon_ld -- ��������ͳ������С�ڵ��� y��m�µ����һ��
                 GROUP BY bpv1.branch, bpv1.month_total, bpv1.year_total) t2
         WHERE t1.branch = t2.branch(+)) mt
 WHERE mt.branch = mcv.company_name(+);


