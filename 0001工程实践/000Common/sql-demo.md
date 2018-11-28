```sql
/*
查询参数：
  branch 分公司
  year   年份
  month  月份
  region 区域
  zone   大区 
*/

-- 年度指标 == [“年度指标”、“月度累计指标”，由“月度分解指标导入”信息来确定。]
SELECT mtv.year_total
  FROM inst_gov_exam_month_target_v mtv
 WHERE mtv.year = 2016
   AND mtv.branch = '江西分公司';

-- 当月完成台数 == [“当月完成台数”：自动计算，数值＝政府验收统计日期从当年当月1日到当月月底的台数总和。]
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
汕头分公司
苏州分公司
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

-- 缺失 SMEC总公司
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
WHERE iac.inst_branch = 'SMEC总公司';

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


-- 当月完成台数 == [“当月完成台数”：自动计算，数值＝政府验收统计日期从当年当月1日到当月月底的台数总和。
SELECT mtv.branch,
       COUNT(1) mon_cmpl -- 当月完成台数
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
   AND gev.gov_exam_stat_date >= TRUNC(to_date('2017-01', 'yyyy-MM'), 'mm') -- 政府验收日期大于等于 2016年3月1日
   AND gev.gov_exam_stat_date <= TRUNC(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2016年3月最后一天
 GROUP BY mtv.branch;

-- “年度指标”、“月度累计指标”，由“月度分解指标导入”信息来确定。 [y]
-- “月度累计完成台数”：自动计算，数值＝政府验收统计日期从1月1日到当月月底的台数总和。 [y]
-- “月度累计完成超差额”：自动计算，数值＝月度累计完成台数－月度累计指标。 [y]
-- “月度指标完成率”：自动计算，数值＝月度累计完成台数÷月度累计指标。 [y]
-- “年度指标完成率”：自动计算，数值＝月度累计完成台数÷年度指标。 [y]
SELECT mtv.branch,
       mtv.year_total, -- 年度指标
       mtv.month_total, -- 月度累计指标
       COUNT(1) mon_cmpl_total, -- 月累计完成台数
       (COUNT(1) - mtv.month_total) mon_cmpl_over, -- 月度累计完成超差额
       ROUND((COUNT(1)/mtv.month_total), 3) mon_cmpl_rate, -- 月度指标完成率
       ROUND((COUNT(1)/mtv.year_total), 3) year_cmpl_rate -- 年度指标完成率
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
   AND gev.gov_exam_stat_date >= TRUNC(to_date('2017-01', 'yyyy-MM'), 'year') -- 政府验收日期大于等于 2017年1月1日
   AND gev.gov_exam_stat_date <= TRUNC(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2017年1月最后一天
 GROUP BY mtv.branch, mtv.month_total, mtv.year_total;

-- “当前待办台数”：自动计算，数值＝总部安装计划员“我的待办”界面关于该分公司的流程数量。
SELECT biv.branch,
       COUNT(1) on_task -- 当前待办台数
  FROM inst_gov_exam_brief_info_v biv
 WHERE biv.doc_status = 'APPROVED'
   AND biv.doc_level = 'INST_PLANNER'
   AND biv.lastupdate_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- 到达"我的待办"节点的时间 大于等于 2017年1月1日
   AND biv.lastupdate_date <=
       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 到达"我的待办"节点的时间 小于等于 2017年1月最后一天
 GROUP BY biv.branch;

SELECT * FROM inst_gov_exam_brep_p1_v;

SELECT t2.branch, -- 分公司
       t2.year_total, -- 年度指标
       t2.month_total, -- 月度累计指标
       t1.mon_cmpl, -- 当月完成台数
       t2.mon_cmpl_total, -- 月度累计完成台数
       t2.mon_cmpl_over, -- 月度累计完成超差额
       t2.mon_cmpl_rate, -- 月度累计指标完成率
       t2.year_cmpl_rate -- 年度指标完成率
  FROM (SELECT rv1.branch, COUNT(1) mon_cmpl -- 当月完成台数
          FROM inst_gov_exam_brep_p1_v rv1
         WHERE rv1.year = 2017
           AND inst_gov_exam_view_pkg.set_month(1) = 1
           AND rv1.gov_exam_stat_date >=
               trunc(to_date('2017-01', 'yyyy-MM'), 'mm') -- 政府验收日期大于等于 2016年3月1日
           AND rv1.gov_exam_stat_date <=
               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2016年3月最后一天
         GROUP BY rv1.branch) t1,
       (SELECT rv2.branch,
               rv2.year_total, -- 年度指标
               rv2.month_total, -- 月度累计指标
               COUNT(1) mon_cmpl_total, -- 月累计完成台数
               (COUNT(1) - rv2.month_total) mon_cmpl_over, -- 月度累计完成超差额
               round((COUNT(1) / rv2.month_total), 3) mon_cmpl_rate, -- 月度指标完成率
               round((COUNT(1) / rv2.year_total), 3) year_cmpl_rate -- 年度指标完成率
          FROM inst_gov_exam_brep_p1_v rv2
         WHERE rv2.year = 2017
           AND inst_gov_exam_view_pkg.set_month(1) = 1
           AND rv2.gov_exam_stat_date >=
               trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- 政府验收日期大于等于 2017年1月1日
           AND rv2.gov_exam_stat_date <=
               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2017年1月最后一天
         GROUP BY rv2.branch, rv2.month_total, rv2.year_total) t2
 WHERE t1.branch = t2.branch;

---------------------------------------------------------------------------------------------------
-- 版本1：发现在计算"当月完成台数"的时候与[pv1.branch = pv2.branch]这样关联可能会丢失数据

SELECT t1.branch,
       t1.year_total, -- 年度指标
       t1.month_total, -- 月度累计指标
       nvl(t2.mon_cmpl, 0) mon_cmpl, -- 当月完成台数
       nvl(t2.mon_cmpl_total, 0) mon_cmpl_total, -- 月度累计完成台数
       nvl(t2.mon_cmpl_over, 0) mon_compl_over, -- 月度累计完成超差额
       nvl(t2.mon_cmpl_rate, 0) mon_compl_rate, -- 月度累计指标完成率
       nvl(t2.year_cmpl_rate, 0) year_compl, -- 年度指标完成率
       t1.on_task -- 当前待办台数
  FROM (SELECT mtv.target_id,
               mtv.branch,
               mtv.year,
               mtv.month,
               mtv.month_total, -- 年度指标
               mtv.year_total, -- 月度累计指标
               NVL(otv.on_task, 0) on_task -- 当前待办台数
          FROM inst_gov_exam_month_target_v mtv,
               (SELECT biv.branch,
                       COUNT(1) on_task -- 当前待办台数
                  FROM inst_gov_exam_brief_info_v biv
                 WHERE biv.doc_status = 'APPROVED'
                   AND biv.doc_level = 'INST_PLANNER'
                   AND biv.lastupdate_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- 到达"我的待办"节点的时间 大于等于 2017年1月1日
                   AND biv.lastupdate_date <=
                       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 到达"我的待办"节点的时间 小于等于 2017年1月最后一天
                 GROUP BY biv.branch) otv
         WHERE mtv.branch = otv.branch(+)) t1,
       (SELECT pv2.branch, -- 分公司
               pv2.year_total, -- 年度指标
               pv2.month_total, -- 月度累计指标
               pv1.mon_cmpl, -- 当月完成台数
               pv2.mon_cmpl_total, -- 月度累计完成台数
               pv2.mon_cmpl_over, -- 月度累计完成超差额
               pv2.mon_cmpl_rate, -- 月度累计指标完成率
               pv2.year_cmpl_rate -- 年度指标完成率
          FROM (SELECT rv1.branch, COUNT(1) mon_cmpl -- 当月完成台数
                  FROM inst_gov_exam_brep_p1_v rv1
                 WHERE rv1.year = 2017
                   AND inst_gov_exam_view_pkg.set_month(1) = 1
                   AND rv1.gov_exam_stat_date >=
                       trunc(to_date('2017-01', 'yyyy-MM'), 'mm') -- 政府验收日期大于等于 2016年3月1日
                   AND rv1.gov_exam_stat_date <=
                       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2016年3月最后一天
                 GROUP BY rv1.branch) pv1,
               (SELECT rv2.branch,
                       rv2.year_total, -- 年度指标
                       rv2.month_total, -- 月度累计指标
                       COUNT(1) mon_cmpl_total, -- 月累计完成台数
                       (COUNT(1) - rv2.month_total) mon_cmpl_over, -- 月度累计完成超差额
                       round((COUNT(1) / rv2.month_total), 3) mon_cmpl_rate, -- 月度指标完成率
                       round((COUNT(1) / rv2.year_total), 3) year_cmpl_rate -- 年度指标完成率
                  FROM inst_gov_exam_brep_p1_v rv2
                 WHERE rv2.year = 2017
                   AND inst_gov_exam_view_pkg.set_month(1) = 1
                   AND rv2.gov_exam_stat_date >=
                       trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- 政府验收日期大于等于 2017年1月1日
                   AND rv2.gov_exam_stat_date <=
                       trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2017年1月最后一天
                 GROUP BY rv2.branch, rv2.month_total, rv2.year_total) pv2
         WHERE pv1.branch = pv2.branch) t2
 WHERE t1.branch = t2.branch(+)
   AND t1.year = 2017;

-----------------------------------------------------------------------------------------------------
-- 版本2解决了版本1可能会丢失数据的问题
SELECT t1.branch,
       t1.year_total, -- 年度指标
       t1.month_total, -- 月度累计指标
       nvl(t1.mon_cmpl, 0) mon_cmpl, -- 当月完成台数
       nvl(t2.mon_cmpl_total, 0) mon_cmpl_total, -- 月度累计完成台数
       nvl(t2.mon_cmpl_over, 0) mon_compl_over, -- 月度累计完成超差额
       nvl(t2.mon_cmpl_rate, 0) mon_compl_rate, -- 月度累计指标完成率
       nvl(t2.year_cmpl_rate, 0) year_compl, -- 年度指标完成率
       t1.on_task -- 当前待办台数
  FROM (SELECT mv1.target_id,
               mv1.branch,
               mv1.year,
               mv1.month,
               mv1.month_total, -- 年度指标
               mv1.year_total, -- 月度累计指标
               mv1.on_task, -- 当前待办台数
               mv2.mon_cmpl -- 当月完成台数
          FROM (SELECT mtv.target_id,
                       mtv.branch,
                       mtv.year,
                       mtv.month,
                       mtv.month_total, -- 年度指标
                       mtv.year_total, -- 月度累计指标
                       NVL(otv.on_task, 0) on_task -- 当前待办台数
                  FROM inst_gov_exam_month_target_v mtv,
                       (SELECT biv1.branch,
                               COUNT(1) on_task -- 当前待办台数
                          FROM inst_gov_exam_brief_info_v biv1
                         WHERE biv1.doc_status = 'APPROVED'
                           AND biv1.doc_level = 'INST_PLANNER'
                           AND biv1.lastupdate_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- 到达"我的待办"节点的时间 大于等于 2017年1月1日
                           AND biv1.lastupdate_date <=
                               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 到达"我的待办"节点的时间 小于等于 2017年1月最后一天
                         GROUP BY biv1.branch) otv
                 WHERE mtv.branch = otv.branch(+)
                   AND mtv.year = 2017) mv1,
               (SELECT biv2.branch, COUNT(1) mon_cmpl -- 当月完成台数
                  FROM inst_gov_exam_brief_info_v biv2
                 WHERE biv2.doc_status = 'COMPLETED'
                   AND biv2.doc_level = 'INST_PLANNER'
                   AND biv2.gov_exam_stat_date >= trunc(to_date('2017-01', 'yyyy-MM'), 'mm') -- 政府验收日期大于等于 2016年3月1日
                   AND biv2.gov_exam_stat_date <= trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2016年3月最后一天
                 GROUP BY biv2.branch) mv2
         WHERE mv1.branch = mv2.branch(+)) t1,
       (SELECT bpv1.branch,
               bpv1.year_total, -- 年度指标
               bpv1.month_total, -- 月度累计指标
               COUNT(1) mon_cmpl_total, -- 月累计完成台数
               (COUNT(1) - bpv1.month_total) mon_cmpl_over, -- 月度累计完成超差额
               round((COUNT(1) / bpv1.month_total), 3) mon_cmpl_rate, -- 月度指标完成率
               round((COUNT(1) / bpv1.year_total), 3) year_cmpl_rate -- 年度指标完成率
          FROM inst_gov_exam_brep_p1_v bpv1
         WHERE bpv1.year = 2017
           AND inst_gov_exam_view_pkg.set_month(1) = 1
           AND bpv1.gov_exam_stat_date >=
               trunc(to_date('2017-01', 'yyyy-MM'), 'year') -- 政府验收日期大于等于 2017年1月1日
           AND bpv1.gov_exam_stat_date <=
               trunc(last_day(to_date('2017-01', 'yyyy-MM')), 'dd') -- 政府验收日期小于等于 2017年1月最后一天
         GROUP BY bpv1.branch, bpv1.month_total, bpv1.year_total) t2
 WHERE t1.branch = t2.branch(+)
   AND t1.year = 2017;

-----------------------------------------------------------------------------------------------------
-- 版本3: 和时间有关的查询条件通过set_date_params来初始化，然后在各个where中通过get获取，并且添加区域(省级分公司)和大区
CREATE OR REPLACE VIEW inst_gov_exam_brep_v AS
SELECT mcv.zone_name, -- 大区
       mcv.pr_comp_name, -- 省级分公司
       mt.branch, -- 分公司
       mt.year_total, -- 年度指标
       mt.month_total, -- 月度累计指标
       mt.mon_cmpl, -- 当月完成台数
       mt.mon_cmpl_total, -- 月度累计完成台数
       mt.mon_cmpl_over, -- 月度累计完成超差额
       mt.mon_cmpl_rate, -- 月度累计指标完成率
       mt.year_cmpl_rate, -- 年度指标完成率
       mt.on_task -- 当前待办台数
  FROM md_company_v mcv,
       (SELECT t1.branch,
               t1.year_total, -- 年度指标
               t1.month_total, -- 月度累计指标
               nvl(t1.mon_cmpl, 0) mon_cmpl, -- 当月完成台数
               nvl(t2.mon_cmpl_total, 0) mon_cmpl_total, -- 月度累计完成台数
               nvl(t2.mon_cmpl_over, 0) mon_cmpl_over, -- 月度累计完成超差额
               nvl(t2.mon_cmpl_rate, 0) mon_cmpl_rate, -- 月度累计指标完成率
               nvl(t2.year_cmpl_rate, 0) year_cmpl_rate, -- 年度指标完成率
               t1.on_task -- 当前待办台数
          FROM (SELECT mv1.branch,
                       mv1.year,
                       mv1.month,
                       mv1.month_total, -- 月度累计指标
                       mv1.year_total, -- 年度指标
                       mv1.on_task, -- 当前待办台数
                       mv2.mon_cmpl -- 当月完成台数
                  FROM (SELECT mtv.branch,
                               mtv.year,
                               mtv.month,
                               mtv.month_total, -- 月度累计指标
                               mtv.year_total, -- 年度指标
                               NVL(otv.on_task, 0) on_task -- 当前待办台数
                          FROM inst_gov_exam_month_target_v mtv,
                               (SELECT biv1.branch,
                                       COUNT(1) on_task -- 当前待办台数
                                  FROM inst_gov_exam_brief_info_v biv1
                                 WHERE biv1.doc_status = 'APPROVED'
                                   AND biv1.doc_level = 'INST_PLANNER'
                                   AND biv1.lastupdate_date >= inst_gov_exam_view_pkg.get_year_fd -- 到达"我的待办"节点的时间 大于等于 y年的第一天
                                   AND biv1.lastupdate_date <= inst_gov_exam_view_pkg.get_mon_ld -- 到达"我的待办"节点的时间 小于等于 y年m月最后一天
                                 GROUP BY biv1.branch) otv
                         WHERE mtv.branch = otv.branch(+)
                           AND mtv.year = inst_gov_exam_view_pkg.get_year) mv1,
                       (SELECT biv2.branch, COUNT(1) mon_cmpl -- 当月完成台数
                          FROM inst_gov_exam_brief_info_v biv2
                         WHERE biv2.doc_status = 'COMPLETED'
                           AND biv2.doc_level = 'INST_PLANNER'
                           AND biv2.gov_exam_stat_date >= inst_gov_exam_view_pkg.get_mon_fd -- 政府验收统计日期大于等于 y年m月的第一天
                           AND biv2.gov_exam_stat_date <= inst_gov_exam_view_pkg.get_mon_ld -- 政府验收统计日期小于等于 y年m月最后一天
                         GROUP BY biv2.branch) mv2
                 WHERE mv1.branch = mv2.branch(+)) t1,
               (SELECT bpv1.branch,
                       COUNT(1) mon_cmpl_total, -- 月累计完成台数
                       (COUNT(1) - bpv1.month_total) mon_cmpl_over, -- 月度累计完成超差额
                       round((COUNT(1) / bpv1.month_total), 3) mon_cmpl_rate, -- 月度指标完成率
                       round((COUNT(1) / bpv1.year_total), 3) year_cmpl_rate -- 年度指标完成率
                  FROM inst_gov_exam_brep_p1_v bpv1
                 WHERE bpv1.year = inst_gov_exam_view_pkg.get_year
                   AND bpv1.gov_exam_stat_date >= inst_gov_exam_view_pkg.get_year_fd -- 政府验收统计日期大于等于 y年的第一天
                   AND bpv1.gov_exam_stat_date <= inst_gov_exam_view_pkg.get_mon_ld -- 政府验收统计日期小于等于 y年m月的最后一天
                 GROUP BY bpv1.branch, bpv1.month_total, bpv1.year_total) t2
         WHERE t1.branch = t2.branch(+)) mt
 WHERE mt.branch = mcv.company_name(+);
```
