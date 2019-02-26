--1.查询" 01 "课程比" 02 "课程成绩高的学生的信息及课程分数
select s.*,sc.cid,sc.score from student s,sc where sc.sid=s.sid and s.sid in (
select t1.sid from 
(select * from sc where CId='01') t1,
(select * from sc where CId='02') t2
where t1.SId=t2.SId and t1.score>t2.score )
--下面一种好些
select * from Student RIGHT JOIN (
    select t1.SId, class1, class2 from
          (select SId, score as class1 from sc where sc.CId = '01')as t1, 
          (select SId, score as class2 from sc where sc.CId = '02')as t2
    where t1.SId = t2.SId AND t1.class1 > t2.class2
)r 
on Student.SId = r.SId;
--1.1 查询同时存在" 01 "课程和" 02 "课程的情况
select t1.*,t2.* from 
(select * from sc where CId='01') t1,
(select * from sc where CId='02') t2
where t1.SId=t2.SId
--1.2 查询存在" 01 "课程但可能不存在" 02 "课程的情况(不存在时显示为 null )
select t1.*,t2.* from 
(select * from sc where CId='01') t1 left join
(select * from sc where CId='02') t2
on t1.SId=t2.SId
--1.3 查询不存在" 01 "课程但存在" 02 "课程的情况
select * from sc where SId not in 
(select SId from sc where CId='01') and CId='02'
--2查询平均成绩大于等于 60 分的同学的学生编号和学生姓名和平均成绩
select SId,avg(score) avg_score from sc group by SId having avg(score) >= '60'
 
select t1.*,st.Sname from 
(select SId,avg(score) avg_score from sc group by SId having avg(score) >= '60') t1,
student st
 where 
st.SId=t1.SId order by avg_score desc;
--3.查询在 SC 表存在成绩的学生信息
select st.* from student st where exists (select 1 from sc where sc.SId=st.SId);
select * from student where SId in (select distinct SId from sc);
--4.查询所有同学的学生编号、学生姓名、选课总数、所有课程的总成绩(没成绩的显示为 null )
select s.SId,s.Sname,count(sc.CId),sum(sc.score) from student s left join sc on sc.SId=s.SId group by SId
--4.1 查有成绩的学生信息   the same as question 3
select s.* from student s where exists (select 1 from sc where sc.SId=s.SId);
--5.查询「李」姓老师的数量
select count(*) cnt from teacher where Tname like '李%';
--6.查询学过「张三」老师授课的同学的信息mysql字段不区分大小写
select s.* from student s ,sc,course c where sc.SId=s.SId and c.CId = sc.CId and c.TId = (select TId from teacher where Tname='张三')
--7.查询没有学全所有课程的同学的信息  转化成在sc表里记录数小于3,但是要注意可能在sc表里没有记录的
select s.* from student s ,sc where s.sid=sc.sid group by s.sid having count(sc.CId)<3 --错误,只能用下面的
select * from student where student.sid not in 
(select sc.sid from sc group by sc.sid having count(sc.cid)=(select count(distinct cid) from course))
--8.查询至少有一门课与学号为" 01 "的同学所学相同的同学的信息
select s.* from student s ,sc where s.sid=sc.sid and sc.cid in (select sc.cid from sc where sid='01') group by s.sid
--或者
select * from student 
where student.sid in (
    select sc.sid from sc 
    where sc.cid in(
        select sc.cid from sc 
        where sc.sid = '01'
    )
);
--9.*查询和" 01 "号的同学学习的课程完全相同的其他同学的信息  这题有点难度
select * from student where sid in 
(select sid from sc where sid not in
(select sid from sc where cid not in (select cid from sc where sid='01')) --修行了01同学没有修行的同学
group by sid 
having count(*)=(select count(*) from sc where sid='01')) --和01修行的课程数一样多，加上上面一条叠加判断
and sid != '01';
--10.查询没学过"张三"老师讲授的任一门课程的学生姓名
select * from student where sid not in(
select sid from sc where cid = (select c.cid from course c ,teacher t where c.tid=t.tid and t.tname='张三'))
--11.查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩  我的错误是count(sc.score<60) >1  count里面是列，不是条件,条件拿到外面拼接,然后having后面一般接统计的
select s.*,avg(sc.score) avg_score from student s,sc where s.sid=sc.sid and sc.score<60  group by sid having count(*)>1
--12.检索" 01 "课程分数小于 60，按分数降序排列的学生信息
select s.*,sc.score from student s,sc where sc.sid=s.sid and sc.score<60 and sc.cid='01' order by sc.score desc
--13按平均成绩从高到低显示所有学生的所有课程的成绩以及平均成绩  这题的思路错了，每门的课程可当做行，因此sc做主表，平均分的做附表
select * from sc left join 
(select sid,avg(score) avg_score from sc group by sid) a on a.sid=sc.sid 
order by a.avg_score desc
--14.查询各科成绩最高分、最低分和平均分：
select cid,max(score),min(score),avg(score) from sc group by cid
--后续  以如下形式显示：课程 ID，课程 name，最高分，最低分，平均分，及格率，中等率，优良率，优秀率
--及格为>=60，中等为：70-80，优良为：80-90，优秀为：>=90
--要求输出课程号和选修人数，查询结果按人数降序排列，若人数相同，按课程号升序排列
select cid,max(score) 最高分,min(score) 最低分,avg(score) 平均分 ,count(*) 选修该课程人数,
sum(case when score>=60 then 1 else 0 end)/count(*) as 及格率,
sum(case when score>=70 and score<80 then 1 else 0 end)/count(*) as 中等率,
sum(case when score>=80 and score<90 then 1 else 0 end)/count(*) as 优良率,
sum(case when score>=90 then 1 else 0 end)/count(*) as 优秀率
from sc group by cid 
order by count(*)  desc,cid asc--两次排序，前面优先级高
--15.按各科成绩进行排序，并显示排名， Score 重复时保留名次空缺
--这题有点难度
select a.cid,a.sid,a.score,count(b.score)+1 as rank
from sc a left join sc b
on a.score<b.score and a.cid=b.cid
group by a.cid,a.sid,a.score
order by a.cid,rank asc;
--16.查询学生的总成绩，并进行排名，总分重复时不保留名次空缺
--这里主要学习一下使用变量。在SQL里面变量用@来标识。:=变量的赋值
set @crank=0;
select q.sid,q.total,@crank := @crank +1 as rank from (
select sc.sid,sum(sc.score) as total from sc group by sc.sid order by total desc) q
--17.统计各科成绩各分数段人数：课程编号，课程名称，[100-85]，[85-70]，[70-60]，[60-0] 及所占百分比
select sc.cid,c.cname,count(*) 总人数,
sum(case when sc.score>=85 then 1 else 0 end )/count(*) '[100-85]',
sum(case when sc.score>=70 and sc.score<85 then 1 else 0 end )/count(*) '[85-70]',
sum(case when sc.score>=60 and sc.score<70 then 1 else 0 end )/count(*) '[70-60]',
sum(case when sc.score<60 then 1 else 0 end )/count(*) '[60-0]'
 from sc,course c where 
sc.cid=c.cid group by sc.cid
--18.查询各科成绩前三名的记录 
--思路1计算比自己分数大的记录有几条，如果小于3 就select
select * from sc where (
select count(*) from sc as a where a.cid=sc.cid and sc.score<a.score) <3
order by cid asc,sc.score desc;
--19.查询每门课程被选修的学生数
select cid,count(sid) from sc group by cid
--20.查询出只选修两门课程的学生学号和姓名
--联合查询
select s.sid,s.sname from student s,sc where sc.sid=s.sid group by s.sid having count(sc.cid)='2' 
--嵌套查询
select sid,sname from student where sid in
(select sid from sc group by sid having count(sc.cid)=2);
--21.查询男生、女生人数
select ssex,count(*) from student group by ssex
--22.查询名字中含有「风」字的学生信息
select * from student where sname like '%风%'
--23.查询同名学生名单，并统计同名人数
select s.sname,count(*) from student s group by sname having count(*)>1
--24.查询 1990 年出生的学生名单
select * from student where sage like '1990%';
select * from student where YEAR(student.Sage)=1990;--日期格式取year month day  time 
--25.查询每门课程的平均成绩，结果按平均成绩降序排列，平均成绩相同时，按课程编号升序排列
select sc.cid,c.cname,avg(score) from sc,course c where sc.cid=c.cid group by sc.cid order by avg(sc.score) desc,sc.cid
--26.查询平均成绩大于等于 85 的所有学生的学号、姓名和平均成绩
select s.sid,s.sname,avg(sc.score) from student s,sc where s.sid=sc.sid group by s.sid having avg(sc.score)>='85'
--27.查询课程名称为「数学」，且分数低于 60 的学生姓名和分数
select s.sname,a.score from student s ,
(select sid,score from sc where cid=(select cid from course where cname='数学') and score <60) a
where s.sid=a.sid
--28.查询所有学生的课程及分数情况（存在学生没成绩，没选课的情况）
select s.sname,sc.cid,sc.score from student s left join sc on s.sid=sc.sid
--29.查询任何一门课程成绩在 70 分以上的姓名、课程名称和分数
select s.sname,c.cname,sc.score from student s,sc,course c where s.sid=sc.sid and sc.cid=c.cid and sc.score>70
--30.查询存在不及格的课程       可以用group by 来取唯一，也可以用distinct
select cid from sc group by cid having min(score)<60
select DISTINCT CId from sc where score <60;
--31.查询课程编号为 01 且课程成绩在 80 分及以上的学生的学号和姓名
select s.sid,s.sname,sc.score from student s,sc where sc.cid='01' and s.sid=sc.sid and sc.score>=80
--32.求每门课程的学生人数
select cid,count(sid) from sc group by cid 
--33.成绩不重复，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
select s.*,sc.score  from student s,sc where s.sid=sc.sid and sc.cid=
(select c.cid from course c,teacher t where c.tid=t.tid and t.tname='张三')
order by sc.score desc limit 1
    --或者
select student.*, sc.score, sc.cid from student, teacher, course,sc 
where teacher.tid = course.tid
and sc.sid = student.sid
and sc.cid = course.cid
and teacher.tname = "张三"
having max(sc.score);
--34.成绩有重复的情况下，查询选修「张三」老师所授课程的学生中，成绩最高的学生信息及其成绩
--思路是查询最高分，然后再查询等于最高分的
--35.查询不同课程成绩相同的学生的学生编号、课程编号、学生成绩
select sc1.* from sc sc1,sc sc2 where sc1.cid<>sc2.cid and sc1.score=sc2.score and sc1.sid=sc2.sid group by sc1.sid,sc1.cid
--36.查询每门成绩最好的前两名   难以理解   放着
select a.* from sc a left join sc b 
on a.cid=b.cid and a.sid=b.sid order by a.cid,a.score desc

select a.sid,a.cid,a.score from sc as a left join sc as b on a.cid = b.cid and a.score<b.score
group by a.cid, a.sid
having count(b.cid)<2
order by a.cid;
--37.统计每门课程的学生选修人数（超过 5 人的课程才统计）
select cid,count(sid) rs from sc group by cid having rs>5 
--38.检索至少选修两门课程的学生学号
select sid,count(cid) from sc group by sid having count(cid)>='2'
--39.查询选修了全部课程的学生信息
select s.* from student s,sc where sc.sid=s.sid group by sc.sid having count(cid)=(select count(distinct(cid)) from sc); 
--40.查询各学生的年龄，只按年份来算
select sname,(year(now())-year(sage)) from student 
--41.按照出生日期来算，当前月日 < 出生年月的月日则，年龄减一
select student.SId as 学生编号,student.Sname  as  学生姓名,TIMESTAMPDIFF(YEAR,student.Sage,CURDATE()) as 学生年龄 from student
--42.查询本周过生日的学生
select * from student where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE());
--43.查询下周过生日的学生
select * from student where WEEKOFYEAR(student.Sage)=WEEKOFYEAR(CURDATE())+1;
--44.查询本月过生日的学生
select * from student where MONTH(student.Sage)=MONTH(CURDATE());
--45.查询下月过生日的学生
select *from student where MONTH(student.Sage)=MONTH(CURDATE())+1;



