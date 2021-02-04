CREATE OR REPLACE PROCEDURE HRBZLS."JOB_SUBMIT" (i_what in varchar,
                                       i_runtime in varchar,
                                       i_interval in varchar default 'null') AS
  jobid  binary_integer;
  runtime date;
BEGIN
  runtime := to_date(i_runtime,'yyyymmdd hh24:mi:ss');
  dbms_job.submit
  (
    job       => jobid,
    what      => i_what,
    next_date => runtime,
    interval  => i_interval,
    no_parse  => NULL
  );
  dbms_output.put_line('JobID = '||jobid);
END job_submit;
/

