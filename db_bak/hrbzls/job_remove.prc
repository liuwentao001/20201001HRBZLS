CREATE OR REPLACE PROCEDURE HRBZLS."JOB_REMOVE" (jobid binary_integer) AS
   BEGIN
      dbms_job.remove
      (
        job    => jobid
      );
      commit;
   END job_remove;
/

