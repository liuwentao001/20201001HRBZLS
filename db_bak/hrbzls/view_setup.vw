create or replace force view hrbzls.view_setup as
select "TBL_NAME","VALUE","PREFIX","CNAME"
    from setup;

