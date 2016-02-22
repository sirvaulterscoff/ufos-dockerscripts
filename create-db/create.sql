--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: ufos; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA ufos;


ALTER SCHEMA ufos OWNER TO ufos;
ALTER USER ufos SET search_path to 'ufos'

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = ufos, pg_catalog;

--
-- Name: brtr_dict_log_change_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION brtr_dict_log_change_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        select nextval('SQ_DictGeneration')
        into NEW.Generation;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.brtr_dict_log_change_function() OWNER TO postgres;

--
-- Name: empty_blob(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION empty_blob() RETURNS bytea
    LANGUAGE plpgsql
    AS $$
    BEGIN  
        return empty_lob();
    END;
$$;


ALTER FUNCTION ufos.empty_blob() OWNER TO postgres;

--
-- Name: java_guid(); Type: FUNCTION; Schema: ufos; Owner: ufos
--

CREATE FUNCTION java_guid() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    BEGIN 
        return uuid_in(md5(random()::text || now()::text)::cstring);
    END;
$$;


ALTER FUNCTION ufos.java_guid() OWNER TO ufos;

--
-- Name: tr_biu_fieldset_addinfo_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_biu_fieldset_addinfo_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        SELECT NAME
	INTO NEW.BUSINESSSTATENAME
	FROM BUSINESSSTATE
	WHERE CODE = NEW.BUSINESSSTATECODE
	limit 1;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_biu_fieldset_addinfo_function() OWNER TO postgres;

--
-- Name: tr_biu_fs_doccommonfields_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_biu_fs_doccommonfields_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
	SELECT NAME
	INTO NEW.BSNAME
	FROM BUSINESSSTATE
	WHERE CODE = NEW.BSCODE
        limit 1;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_biu_fs_doccommonfields_function() OWNER TO postgres;

--
-- Name: tr_bnu_fieldset_addinfo_before_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_bnu_fieldset_addinfo_before_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
	col NUMERIC;
    BEGIN
    IF OLD != NULL THEN
        IF NEW.BUSINESSSTATECODE = OLD.BUSINESSSTATECODE AND (NEW.BUSINESSSTATENAME != OLD.BUSINESSSTATENAME
                                                                 OR NEW.BUSINESSSTATENAME IS NULL) THEN
            select COUNT(*) into col from BUSINESSSTATE WHERE CODE = NEW.BUSINESSSTATECODE and NAME = NEW.BUSINESSSTATENAME;
            IF col = 0 THEN
            BEGIN
                SELECT NAME INTO NEW.BUSINESSSTATENAME FROM BUSINESSSTATE WHERE CODE = NEW.BUSINESSSTATECODE LIMIT 1;
            END;
	        END IF;
	    END IF;
	END IF; 
    RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_bnu_fieldset_addinfo_before_function() OWNER TO postgres;

--
-- Name: tr_dict_change_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_dict_change_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        select nextval('SQ_DictGeneration'), current_timestamp
        into NEW.localrplversion, NEW.localrpltimestamp;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_dict_change_function() OWNER TO postgres;

--
-- Name: tr_doctype_dictionary_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_doctype_dictionary_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        IF (NEW.dictionary != OLD.dictionary) THEN
            RAISE EXCEPTION 'It''s a bad idea to update dictionary column of docType table.';
        END IF;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_doctype_dictionary_function() OWNER TO postgres;

--
-- Name: tr_globaldicid_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_globaldicid_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        if (NEW.GLOBALDICID is null) then
            select java_guid() into NEW.GLOBALDICID;
        end if;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_globaldicid_function() OWNER TO postgres;

--
-- Name: tr_ins_tnk_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_ins_tnk_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        if (NEW.doc_type_systemname is NOT NULL) then
            SELECT doctypeid INTO NEW.id_doc_type FROM doctype dt WHERE dt.systemname = NEW.doc_type_systemname;
        end if;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_ins_tnk_function() OWNER TO postgres;

--
-- Name: tr_insert_routecontext_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_insert_routecontext_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        SELECT docStateId INTO NEW.docStateId FROM ufos.doc d WHERE d.docId = NEW.docId;
        SELECT docTypeId INTO NEW.docTypeId FROM ufos.doc ad WHERE ad.docId = NEW.docId;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_insert_routecontext_function() OWNER TO postgres;

--
-- Name: tr_insert_task_history_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_insert_task_history_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    DECLARE
	tmp NUMERIC;
    BEGIN
	SELECT COUNT(*) INTO tmp FROM TASK_HISTORY WHERE USERID = new.USERID;
	IF tmp > 100  then
		DELETE FROM TASK_HISTORY task where task.CREATED = (SELECT MIN(th.CREATED) FROM TASK_HISTORY th where th.USERID=new.USERID);
	END IF;
	RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_insert_task_history_function() OWNER TO postgres;

--
-- Name: tr_instatenumber_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_instatenumber_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
	if (new.instatenumber < old.instatenumber) then
		new.instatenumber := old.instatenumber;
	end if;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_instatenumber_function() OWNER TO postgres;

--
-- Name: tr_last_update_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_last_update_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        if ((NEW.LAST_UPDATE_DATE = OLD.LAST_UPDATE_DATE) or (OLD.LAST_UPDATE_DATE is null and NEW.LAST_UPDATE_DATE is null)) then
            NEW.LAST_UPDATE_DATE := current_timestamp;
            NEW.username := 'sysdba';
        end if;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_last_update_function() OWNER TO postgres;

--
-- Name: tr_pk_id_function(); Type: FUNCTION; Schema: ufos; Owner: ufos
--

CREATE FUNCTION tr_pk_id_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        SELECT nextval('hibernate_sequence') INTO NEW.id;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_pk_id_function() OWNER TO ufos;

--
-- Name: tr_sysconst_modification_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_sysconst_modification_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        if ((NEW.LAST_UPDATE_DATE = OLD.LAST_UPDATE_DATE) or (OLD.LAST_UPDATE_DATE is null and NEW.LAST_UPDATE_DATE is null)) then
            NEW.LAST_UPDATE_DATE := current_timestamp;
            NEW.username := 'sysdba';
        end if;
        NEW.prevvalue := OLD.value;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_sysconst_modification_function() OWNER TO postgres;

--
-- Name: tr_tb_message_big_attributes_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_tb_message_big_attributes_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        select nextval('SQ_TB_MESSAGE_BIG_ATTRIBUTES')
        into NEW.id;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_tb_message_big_attributes_function() OWNER TO postgres;

--
-- Name: tr_update_dictstateid_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_update_dictstateid_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        update ufos.fs_dictcommonfields set docstateid = NEW.docstateid where dictid = NEW.dictid;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_update_dictstateid_function() OWNER TO postgres;

--
-- Name: tr_update_docstateid_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_update_docstateid_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        UPDATE ufos.routeContext SET docStateId = NEW.docStateId WHERE docId = NEW.docId;
        UPDATE ufos.fs_doccommonfields SET docStateId = NEW.docStateId WHERE docId = NEW.docId;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_update_docstateid_function() OWNER TO postgres;

--
-- Name: tr_update_doctypeid_function(); Type: FUNCTION; Schema: ufos; Owner: postgres
--

CREATE FUNCTION tr_update_doctypeid_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN
        UPDATE ufos.routeContext SET docTypeId = NEW.docTypeId WHERE docId = NEW.docId;
        UPDATE ufos.fs_doccommonfields SET docTypeId = NEW.docTypeId WHERE docId = NEW.docId;
        RETURN NEW;
    END;
$$;


ALTER FUNCTION ufos.tr_update_doctypeid_function() OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: java_guid(); Type: FUNCTION; Schema: public; Owner: ufos
--

CREATE FUNCTION java_guid() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
    BEGIN 
        return uuid_in(md5(random()::text || now()::text)::cstring);
    END;
$$;


ALTER FUNCTION public.java_guid() OWNER TO ufos;

SET search_path = ufos, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;


CREATE TABLE admincontext (
    contextid numeric NOT NULL,
    version numeric,
    name character varying(255),
    defaultofficetypeid numeric,
    defaultcomplextypeid numeric,
    defaultorgtypeid numeric,
    creditofficetypeid numeric,
    creditcomplextypeid numeric
);


ALTER TABLE admincontext OWNER TO ufos;

--
-- Name: adminservice; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE adminservice (
    adminserviceid numeric NOT NULL,
    systemname character varying(255),
    name character varying(255),
    path_to_icon character varying(100)
);


ALTER TABLE adminservice OWNER TO ufos;

--
-- Name: adminsubmenu; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE adminsubmenu (
    adminsubmenuid numeric NOT NULL,
    systemname character varying(255),
    name character varying(255),
    adminserviceid numeric,
    path_to_icon character varying(100),
    path_to_component character varying(100),
    security_required numeric(1,0) DEFAULT 0 NOT NULL,
    defaultvisible numeric(1,0) DEFAULT 0 NOT NULL
);


ALTER TABLE adminsubmenu OWNER TO ufos;

--
-- Name: alerts; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE alerts (
    alertid numeric(21,0) NOT NULL,
    systemname character varying(255) NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE alerts OWNER TO ufos;

--
-- Name: ap_argument_value; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_argument_value (
    id numeric(19,0) NOT NULL,
    task_id numeric(19,0),
    value character varying(255) NOT NULL,
    guid character varying(128),
    operationarg character varying(255) DEFAULT 'default'::character varying NOT NULL
);


ALTER TABLE ap_argument_value OWNER TO ufos;

--
-- Name: ap_condition; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_condition (
    id numeric(19,0) NOT NULL,
    version numeric(10,0) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    guid character varying(128),
    description character varying(255)
);


ALTER TABLE ap_condition OWNER TO ufos;

--
-- Name: ap_condition_calendar; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_condition_calendar (
    id numeric(19,0) NOT NULL,
    expression character varying(255) NOT NULL
);


ALTER TABLE ap_condition_calendar OWNER TO ufos;

--
-- Name: ap_condition_event; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_condition_event (
    id numeric NOT NULL,
    startkey character varying(50) NOT NULL
);


ALTER TABLE ap_condition_event OWNER TO ufos;

--
-- Name: ap_condition_file; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_condition_file (
    id numeric(19,0) NOT NULL,
    path character varying(255) NOT NULL,
    mask character varying(255)
);


ALTER TABLE ap_condition_file OWNER TO ufos;

--
-- Name: ap_condition_posttask; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_condition_posttask (
    id numeric(19,0) NOT NULL,
    precede_task_id numeric(19,0) NOT NULL
);


ALTER TABLE ap_condition_posttask OWNER TO ufos;

--
-- Name: ap_task; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_task (
    id numeric(19,0) NOT NULL,
    version numeric(10,0) NOT NULL,
    name character varying(255) NOT NULL,
    enabled boolean,
    priority character varying(255),
    init_system boolean,
    guid character varying(128),
    execoperation character varying(200)
);


ALTER TABLE ap_task OWNER TO ufos;

--
-- Name: ap_task_j_condition; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_task_j_condition (
    task_id numeric(19,0) NOT NULL,
    condition_id numeric(19,0) NOT NULL
);


ALTER TABLE ap_task_j_condition OWNER TO ufos;

--
-- Name: ap_task_process_journal; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE ap_task_process_journal (
    id numeric NOT NULL,
    task_name character varying(400) NOT NULL,
    start_time timestamp(6) without time zone NOT NULL,
    elapsed_time numeric,
    process_status character varying(200) NOT NULL,
    message text NOT NULL,
    task_guid character varying(36),
    task_id numeric(19,0)
);


ALTER TABLE ap_task_process_journal OWNER TO ufos;

--
-- Name: approvalset; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE approvalset (
    approvalsetid numeric NOT NULL,
    version numeric,
    name character varying(128),
    doctypeid numeric NOT NULL,
    actionid numeric
);


ALTER TABLE approvalset OWNER TO ufos;

--
-- Name: area; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE area (
    dict_id numeric NOT NULL,
    areaname character varying(255),
    areacode character varying(8)
);


ALTER TABLE area OWNER TO ufos;

--
-- Name: attach; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE attach (
    attachid numeric NOT NULL,
    version numeric,
    mimetype character varying(73),
    filename character varying(255),
    filedate date,
    filepath character varying(255),
    filecontent bytea,
    comment_info character varying(2000),
    business_type character varying(255),
    guid character varying(36) NOT NULL,
    ordinal_number numeric(9,0) DEFAULT 1 NOT NULL,
    contentdate date,
    title character varying(255),
    createorgtitle character varying(255),
    createusertitle character varying(255),
    viewable character(1) DEFAULT 'N'::bpchar NOT NULL,
    status character varying(50),
    temporary character(1) DEFAULT 'N'::bpchar NOT NULL,
    filesize numeric NOT NULL,
    docid_old numeric(19,0),
    wccid character varying(30),
    annotation character varying(255),
    service character(1) DEFAULT 'N'::bpchar NOT NULL,
    CONSTRAINT attach_service_chk CHECK ((service = ANY (ARRAY['N'::bpchar, 'Y'::bpchar]))),
    CONSTRAINT ch_attach_temporary_01 CHECK ((temporary = ANY (ARRAY['Y'::bpchar, 'N'::bpchar]))),
    CONSTRAINT ch_attach_viewable_02 CHECK ((viewable = ANY (ARRAY['Y'::bpchar, 'N'::bpchar]))),
    CONSTRAINT ck_attach_guid CHECK (((guid)::text = lower((guid)::text)))
);


ALTER TABLE attach OWNER TO ufos;

--
-- Name: attach_dict; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE attach_dict (
    attachid numeric NOT NULL,
    dictid numeric NOT NULL
);


ALTER TABLE attach_dict OWNER TO ufos;

--
-- Name: attach_doc; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE attach_doc (
    attachid numeric NOT NULL,
    docid numeric NOT NULL
);


ALTER TABLE attach_doc OWNER TO ufos;

--
-- Name: auditgroup; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE auditgroup (
    auditgroupid numeric NOT NULL,
    version numeric,
    used boolean,
    grouptype character varying(50)
);


ALTER TABLE auditgroup OWNER TO ufos;

--
-- Name: auditlog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE auditlog (
    eventid numeric NOT NULL,
    eventdate date,
    officeid numeric,
    userid numeric,
    username character varying(255),
    entitytype character varying(100),
    eventtype character varying(100),
    entityid numeric,
    info character varying(255)
);


ALTER TABLE auditlog OWNER TO ufos;


--
-- Name: boolean_cols; Type: TABLE; Schema: ufos; Owner: postgres; Tablespace: 
--

CREATE TABLE boolean_cols (
    table_name character varying(100) NOT NULL,
    column_name character varying(100) NOT NULL
);


ALTER TABLE boolean_cols OWNER TO postgres;


--
-- Name: build_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE build_info (
    build_id numeric NOT NULL,
    build_num character varying(10),
    build_data date,
    build_target character varying(10),
    build_type numeric,
    build_ref character varying(10)
);


ALTER TABLE build_info OWNER TO ufos;

--
-- Name: build_item; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE build_item (
    item_id numeric NOT NULL,
    item_name character varying(64),
    build_id numeric,
    item_description character varying(255),
    load_status character(3)
);


ALTER TABLE build_item OWNER TO ufos;


CREATE TABLE categories (
    code character varying(20),
    name character varying(100),
    version numeric,
    id numeric NOT NULL,
    globaldicid character varying(128) NOT NULL
);


ALTER TABLE categories OWNER TO ufos;


--
-- Name: cg_algorithm; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_algorithm (
    id numeric NOT NULL,
    name character varying(200),
    description character varying(4000),
    type character varying(200),
    version numeric NOT NULL
);


ALTER TABLE cg_algorithm OWNER TO ufos;

--
-- Name: COLUMN cg_algorithm.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_algorithm.id IS 'Идентификатор описания алгоритма';


--
-- Name: COLUMN cg_algorithm.name; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_algorithm.name IS 'Наименование алгоритма';


--
-- Name: COLUMN cg_algorithm.description; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_algorithm.description IS 'Описание алгоритма';


--
-- Name: COLUMN cg_algorithm.type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_algorithm.type IS 'Тип алгоритма';


--
-- Name: cg_attach_sign_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_attach_sign_info (
    id numeric NOT NULL,
    attach_id numeric NOT NULL
);


ALTER TABLE cg_attach_sign_info OWNER TO ufos;

--
-- Name: COLUMN cg_attach_sign_info.attach_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_attach_sign_info.attach_id IS 'Идентификатор вложения';


--
-- Name: cg_basecrl_update_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_basecrl_update_info (
    this_update timestamp(6) without time zone NOT NULL,
    authority_key_id character varying(60) NOT NULL
);


ALTER TABLE cg_basecrl_update_info OWNER TO ufos;

--
-- Name: cg_cert_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_cert_info (
    id numeric NOT NULL,
    fingerprint character varying(200) NOT NULL,
    is_4encrypt boolean,
    is_4sign boolean,
    name character varying(200) NOT NULL,
    revoked_date timestamp(6) without time zone,
    is_temp boolean,
    prev_cert_fingerprint character varying(200),
    start_valid_date timestamp(6) without time zone NOT NULL,
    end_valid_date timestamp(6) without time zone NOT NULL,
    is_4data boolean,
    subject_key_identifier character varying(200) NOT NULL,
    has_privatekey_link boolean,
    version numeric NOT NULL,
    authorization_usage character varying(50) DEFAULT 'NotConsidered'::character varying NOT NULL,
    cert_bytes bytea,
    userinfo_name character varying(255) DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE cg_cert_info OWNER TO ufos;

--
-- Name: TABLE cg_cert_info; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE cg_cert_info IS 'Описание сертификата';


--
-- Name: COLUMN cg_cert_info.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.id IS 'Идентификатор описания сертификата';


--
-- Name: COLUMN cg_cert_info.fingerprint; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.fingerprint IS 'Отпечаток сертификата';


--
-- Name: COLUMN cg_cert_info.is_4encrypt; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.is_4encrypt IS 'возможность использования сертификата для шифрования';


--
-- Name: COLUMN cg_cert_info.is_4sign; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.is_4sign IS 'возможность использования сертификата для подписи';


--
-- Name: COLUMN cg_cert_info.name; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.name IS 'Наименование описания сертификата (для GUI)';


--
-- Name: COLUMN cg_cert_info.revoked_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.revoked_date IS 'Дата отзыва сертификата';


--
-- Name: COLUMN cg_cert_info.is_temp; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.is_temp IS 'Признак временного';


--
-- Name: COLUMN cg_cert_info.prev_cert_fingerprint; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.prev_cert_fingerprint IS 'Отпечаток предыдущего сертификата';


--
-- Name: COLUMN cg_cert_info.start_valid_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.start_valid_date IS 'дата начала действия сертификата';


--
-- Name: COLUMN cg_cert_info.end_valid_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.end_valid_date IS 'дата окончания действия сертификата';


--
-- Name: COLUMN cg_cert_info.is_4data; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.is_4data IS 'Поддержка для данных';


--
-- Name: COLUMN cg_cert_info.subject_key_identifier; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.subject_key_identifier IS 'Идентификатор сертификата';


--
-- Name: COLUMN cg_cert_info.has_privatekey_link; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.has_privatekey_link IS 'Привязан ли приватный ключ к сертификату';


--
-- Name: COLUMN cg_cert_info.authorization_usage; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_info.authorization_usage IS 'Текущий статус использования сертификата для авторизации';


--
-- Name: cg_cert_j_doctype; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_cert_j_doctype (
    cert_info_id numeric NOT NULL,
    doc_type_id numeric NOT NULL
);


ALTER TABLE cg_cert_j_doctype OWNER TO ufos;

--
-- Name: COLUMN cg_cert_j_doctype.cert_info_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_j_doctype.cert_info_id IS 'Идентификатор описания сертификата';


--
-- Name: COLUMN cg_cert_j_doctype.doc_type_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_j_doctype.doc_type_id IS 'Идентификатор типа документа';


--
-- Name: cg_cert_j_substitution; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_cert_j_substitution (
    cert_info_id numeric NOT NULL,
    user_substitution_id numeric NOT NULL
);


ALTER TABLE cg_cert_j_substitution OWNER TO ufos;

--
-- Name: TABLE cg_cert_j_substitution; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE cg_cert_j_substitution IS 'Связка сертификата и замещения';


--
-- Name: COLUMN cg_cert_j_substitution.cert_info_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_j_substitution.cert_info_id IS 'Идентификатор описания сертификата';


--
-- Name: COLUMN cg_cert_j_substitution.user_substitution_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_cert_j_substitution.user_substitution_id IS 'Идентификатор замещения';


--
-- Name: cg_csp_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_csp_info (
    id numeric NOT NULL,
    provider_jclass character varying(200) NOT NULL,
    sign_algorithm_id numeric NOT NULL,
    hash_algorithm_id numeric NOT NULL,
    cipher_algorithm_id numeric NOT NULL,
    is_active boolean,
    is_win32 boolean,
    name character varying(200) NOT NULL,
    description character varying(4000),
    init_params character varying(4000),
    version numeric NOT NULL
);


ALTER TABLE cg_csp_info OWNER TO ufos;

--
-- Name: TABLE cg_csp_info; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE cg_csp_info IS 'Криптопровайдер';


--
-- Name: COLUMN cg_csp_info.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.id IS 'Идентификатор описания криптопровайдера';


--
-- Name: COLUMN cg_csp_info.sign_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.sign_algorithm_id IS 'Алгоритм подписи';


--
-- Name: COLUMN cg_csp_info.hash_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.hash_algorithm_id IS 'Алгоритм хэширования';


--
-- Name: COLUMN cg_csp_info.cipher_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.cipher_algorithm_id IS 'Алгоритм шифрования';


--
-- Name: COLUMN cg_csp_info.is_active; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.is_active IS 'Признак активного';


--
-- Name: COLUMN cg_csp_info.is_win32; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.is_win32 IS 'Признак Win32';


--
-- Name: COLUMN cg_csp_info.name; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.name IS 'Наименование криптопровайдера';


--
-- Name: COLUMN cg_csp_info.description; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.description IS 'Описание';


--
-- Name: COLUMN cg_csp_info.init_params; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_csp_info.init_params IS 'Параметры инициализации';


--
-- Name: cg_doc_sign_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_doc_sign_info (
    id numeric NOT NULL,
    sign_scheme_id numeric,
    scheme_name character varying(30),
    is_new_algorithm boolean DEFAULT false,
    docid numeric
);


ALTER TABLE cg_doc_sign_info OWNER TO ufos;

--
-- Name: COLUMN cg_doc_sign_info.sign_scheme_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_doc_sign_info.sign_scheme_id IS 'Идентификатор схемы подписи';


--
-- Name: cg_exserv_connection; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_exserv_connection (
    id numeric NOT NULL,
    type character varying(200) NOT NULL,
    url character varying(4000) NOT NULL,
    name character varying(4000) NOT NULL,
    description character varying(4000),
    extra_params character varying(4000),
    last_date timestamp(6) without time zone,
    last_error_code character varying(200),
    last_err_mess character varying(4000),
    status character varying(200),
    version numeric NOT NULL,
    ca_fingerprint character varying(200) DEFAULT '9b 95 50 5c 27 e2 ac c0 3b ab 76 91 fa 52 99 c6 52 ce 2c 50'::character varying NOT NULL
);


ALTER TABLE cg_exserv_connection OWNER TO ufos;

--
-- Name: TABLE cg_exserv_connection; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE cg_exserv_connection IS 'Соединение с внешним сервисом';


--
-- Name: COLUMN cg_exserv_connection.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.id IS 'Идентификатор соединения';


--
-- Name: COLUMN cg_exserv_connection.type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.type IS 'Тип сервиса';


--
-- Name: COLUMN cg_exserv_connection.url; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.url IS 'Локатор сервиса';


--
-- Name: COLUMN cg_exserv_connection.name; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.name IS 'Наименование сервиса (для GUI)';


--
-- Name: COLUMN cg_exserv_connection.description; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.description IS 'Описание';


--
-- Name: COLUMN cg_exserv_connection.extra_params; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.extra_params IS 'Дополн. параметры';


--
-- Name: COLUMN cg_exserv_connection.last_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.last_date IS 'Время последнего обращения';


--
-- Name: COLUMN cg_exserv_connection.last_error_code; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.last_error_code IS 'Последний код ошибки';


--
-- Name: COLUMN cg_exserv_connection.last_err_mess; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.last_err_mess IS 'Последнее сообщение об ошибке';


--
-- Name: COLUMN cg_exserv_connection.status; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.status IS 'Статус соединения';


--
-- Name: COLUMN cg_exserv_connection.ca_fingerprint; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_exserv_connection.ca_fingerprint IS 'Отпечаток сертификата УУЦ';


--
-- Name: cg_process; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_process (
    docid numeric,
    doctype character varying(20),
    title character varying(2)
);


ALTER TABLE cg_process OWNER TO ufos;

--
-- Name: cg_process_docs; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_process_docs (
    docid numeric,
    doctype character varying(20)
);


ALTER TABLE cg_process_docs OWNER TO ufos;

--
-- Name: cg_process_doctypes; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_process_doctypes (
    doctype character varying(20),
    doctable character varying(30)
);


ALTER TABLE cg_process_doctypes OWNER TO ufos;

--
-- Name: cg_process_ofk; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_process_ofk (
    orgid numeric
);


ALTER TABLE cg_process_ofk OWNER TO ufos;

--
-- Name: cg_protection_desc; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_protection_desc (
    id numeric NOT NULL,
    cipher_algorithm_id numeric,
    hash_algorithm_id numeric,
    type character varying(200) NOT NULL,
    key_pattern character varying(200),
    inset_flag boolean DEFAULT false,
    inset_length numeric DEFAULT 0,
    inset_mask bytea,
    change_date timestamp(6) without time zone NOT NULL,
    active boolean DEFAULT false NOT NULL,
    version numeric NOT NULL
);


ALTER TABLE cg_protection_desc OWNER TO ufos;

--
-- Name: COLUMN cg_protection_desc.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.id IS 'Идентификатор набора опций защиты';


--
-- Name: COLUMN cg_protection_desc.cipher_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.cipher_algorithm_id IS 'Алгоритм шифрования';


--
-- Name: COLUMN cg_protection_desc.hash_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.hash_algorithm_id IS 'Алгоритм хэширования';


--
-- Name: COLUMN cg_protection_desc.type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.type IS 'Тип защиты';


--
-- Name: COLUMN cg_protection_desc.key_pattern; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.key_pattern IS 'Шаблон ключа или пароля';


--
-- Name: COLUMN cg_protection_desc.inset_flag; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.inset_flag IS 'Флаг имитовставки';


--
-- Name: COLUMN cg_protection_desc.inset_length; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.inset_length IS 'Длина имитовставки';


--
-- Name: COLUMN cg_protection_desc.inset_mask; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.inset_mask IS 'Маска имитовставки';


--
-- Name: COLUMN cg_protection_desc.change_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.change_date IS 'Дата смены ключа или пароля';


--
-- Name: COLUMN cg_protection_desc.active; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_protection_desc.active IS 'Активная или нет опция настройки защиты. Используется только активная. Для каждого уровня защиты активной может быть только одна. ';


--
-- Name: cg_sign_info; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_sign_info (
    id numeric NOT NULL,
    cipher_algorithm_id numeric,
    hash_algorithm_id numeric,
    csp_info_id numeric,
    cert_fingerprint character varying(200),
    subject_cname character varying(200),
    subject_title character varying(200),
    subject_org character varying(2000),
    is_local boolean,
    creation_date timestamp(6) without time zone,
    is_advanced boolean,
    adv_status character varying(200) NOT NULL,
    adv_error_code character varying(600),
    adv_error_mess character varying(4000),
    last_check_status character varying(200) NOT NULL,
    last_check_date timestamp(6) without time zone,
    version numeric NOT NULL,
    guid character varying(128),
    last_inspector_sysname character varying(50),
    what_signed character varying(50) NOT NULL,
    subject_org_system_name character varying(255),
    creation_login character varying(256),
    sign_format character varying(30) DEFAULT 'CMS'::character varying,
    user_name character varying(255),
    cms_signed_data oid,
    certifying_hash oid,
    signed_data oid
);


ALTER TABLE cg_sign_info OWNER TO ufos;

--
-- Name: COLUMN cg_sign_info.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.id IS 'Идентификатор описания подписи';


--
-- Name: COLUMN cg_sign_info.cipher_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.cipher_algorithm_id IS 'Идентификатор алгоритма шифрования';


--
-- Name: COLUMN cg_sign_info.hash_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.hash_algorithm_id IS 'Идентификатор алгоритма хэширования';


--
-- Name: COLUMN cg_sign_info.csp_info_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.csp_info_id IS 'Идентификатор описания криптопровайдера';


--
-- Name: COLUMN cg_sign_info.cert_fingerprint; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.cert_fingerprint IS 'Отпечаток сертификата';


--
-- Name: COLUMN cg_sign_info.subject_cname; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.subject_cname IS 'ФИО пользователя';


--
-- Name: COLUMN cg_sign_info.subject_title; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.subject_title IS 'Должность пользователя';


--
-- Name: COLUMN cg_sign_info.subject_org; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.subject_org IS 'Наименование организации пользователя';


--
-- Name: COLUMN cg_sign_info.is_local; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.is_local IS 'Подпись сделана локальным пользователем';


--
-- Name: COLUMN cg_sign_info.creation_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.creation_date IS 'Дата создания подписи';


--
-- Name: COLUMN cg_sign_info.is_advanced; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.is_advanced IS 'Усовершенствованная подпись или нет';


--
-- Name: COLUMN cg_sign_info.adv_status; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.adv_status IS 'Статус дополнения до УЭЦП';


--
-- Name: COLUMN cg_sign_info.adv_error_code; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.adv_error_code IS 'Код ошибки формирования УЭЦП';


--
-- Name: COLUMN cg_sign_info.adv_error_mess; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.adv_error_mess IS 'Описание ошибки формирования УЭЦП';


--
-- Name: COLUMN cg_sign_info.last_check_status; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.last_check_status IS 'Статус последней проверки';


--
-- Name: COLUMN cg_sign_info.last_check_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.last_check_date IS 'Дата последней проверки';


--
-- Name: COLUMN cg_sign_info.last_inspector_sysname; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.last_inspector_sysname IS 'Системное наименование пользователя, который последним проверял ЭЦП';


--
-- Name: COLUMN cg_sign_info.what_signed; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_info.what_signed IS 'Что подписано';


--
-- Name: cg_sign_scheme; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_sign_scheme (
    id numeric NOT NULL,
    doc_type_id numeric NOT NULL,
    name character varying(200) NOT NULL,
    description character varying(4000),
    content bytea NOT NULL,
    active boolean DEFAULT false NOT NULL,
    version numeric NOT NULL,
    guid character varying(128),
    distributed boolean DEFAULT false NOT NULL,
    conditions bytea,
    pattern_version numeric DEFAULT 0 NOT NULL,
    scheme_version numeric DEFAULT 0 NOT NULL,
    raw_content bytea NOT NULL,
    start_date date,
    start_date_default date
);


ALTER TABLE cg_sign_scheme OWNER TO ufos;

--
-- Name: TABLE cg_sign_scheme; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE cg_sign_scheme IS 'Схема подписи';


--
-- Name: COLUMN cg_sign_scheme.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.id IS 'Идентификатор описания схемы подписи';


--
-- Name: COLUMN cg_sign_scheme.doc_type_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.doc_type_id IS 'Идентификатор типа документа';


--
-- Name: COLUMN cg_sign_scheme.name; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.name IS 'Наименование схемы подписи';


--
-- Name: COLUMN cg_sign_scheme.description; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.description IS 'Описание';


--
-- Name: COLUMN cg_sign_scheme.content; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.content IS 'Содержание схемы подписи';


--
-- Name: COLUMN cg_sign_scheme.active; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.active IS 'Флаг, указывающий активна в текущий момент схема подписи или нет. Активной для конкретного типа документа может быть только одна схема';


--
-- Name: COLUMN cg_sign_scheme.conditions; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_sign_scheme.conditions IS 'Содержит хэш, подтверждающий аннулирование замещения(для закрытого комплекса)';


--
-- Name: cg_sscheme_changing_track; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_sscheme_changing_track (
    id numeric(19,0) NOT NULL,
    sign_scheme_id numeric(19,0) NOT NULL,
    raw_content bytea NOT NULL,
    content bytea NOT NULL,
    record_date timestamp(6) without time zone NOT NULL,
    version numeric NOT NULL,
    userinfo_id numeric NOT NULL
);


ALTER TABLE cg_sscheme_changing_track OWNER TO ufos;

--
-- Name: cg_user_profile; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_user_profile (
    id numeric NOT NULL,
    arch_algorithm_id numeric,
    checksum_algorithm_id numeric,
    userinfo_id numeric NOT NULL,
    protection_level character varying(200) NOT NULL,
    usercert_fingerprint character varying(200),
    protect_desc_min_id numeric,
    protect_desc_av_id numeric,
    version numeric NOT NULL,
    formalized_title character varying(100),
    name character varying(255),
    userinfo_systemname character varying(255) DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE cg_user_profile OWNER TO ufos;

--
-- Name: COLUMN cg_user_profile.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.id IS 'Идентификатор профиля пользователя';


--
-- Name: COLUMN cg_user_profile.arch_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.arch_algorithm_id IS 'Идентификатор алгоритм архивирования';


--
-- Name: COLUMN cg_user_profile.checksum_algorithm_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.checksum_algorithm_id IS 'Алгоритм подсчета контрольной суммы';


--
-- Name: COLUMN cg_user_profile.userinfo_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.userinfo_id IS 'Идентификатор описания пользователя';


--
-- Name: COLUMN cg_user_profile.protection_level; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.protection_level IS 'Уровень защиты';


--
-- Name: COLUMN cg_user_profile.usercert_fingerprint; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.usercert_fingerprint IS 'Отпечаток сертификата пользователя';


--
-- Name: COLUMN cg_user_profile.protect_desc_min_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.protect_desc_min_id IS 'Описание минимальной защиты';


--
-- Name: COLUMN cg_user_profile.protect_desc_av_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_profile.protect_desc_av_id IS 'Описание максимальной защиты';


--
-- Name: cg_user_substitution; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cg_user_substitution (
    id numeric NOT NULL,
    substed_userinfo_id numeric NOT NULL,
    substing_userinfo_id numeric NOT NULL,
    substed_subject_cn character varying(400),
    substed_subject_org character varying(400),
    substed_subject_title character varying(400),
    substing_subject_cn character varying(400),
    substing_subject_org character varying(400),
    substing_subject_title character varying(400),
    start_valid_date timestamp(6) without time zone NOT NULL,
    end_valid_date timestamp(6) without time zone NOT NULL,
    nullification_date timestamp(6) without time zone,
    nullification_cms_sign bytea,
    is_passable numeric(1,0) DEFAULT 0 NOT NULL,
    prev_user_substit_id numeric,
    description character varying(4000),
    nullification_uhash_data bytea,
    substed_userinfo_name character varying(255) DEFAULT 'none'::character varying NOT NULL,
    substing_userinfo_name character varying(255) DEFAULT 'none'::character varying NOT NULL
);


ALTER TABLE cg_user_substitution OWNER TO ufos;

--
-- Name: TABLE cg_user_substitution; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE cg_user_substitution IS 'Описание пользовательского замещения на право подписи документов';


--
-- Name: COLUMN cg_user_substitution.id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.id IS 'Идентификатор замещения';


--
-- Name: COLUMN cg_user_substitution.substed_userinfo_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substed_userinfo_id IS 'Идентификатор пользователя, которого замещают';


--
-- Name: COLUMN cg_user_substitution.substing_userinfo_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substing_userinfo_id IS 'Идентификатор пользователя, который замещает';


--
-- Name: COLUMN cg_user_substitution.substed_subject_cn; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substed_subject_cn IS 'CN(ФИО) из сертификата/УХ пользователя, которого замещают ';


--
-- Name: COLUMN cg_user_substitution.substed_subject_org; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substed_subject_org IS 'Организация из сертификата/УХ пользователя, которого замещают ';


--
-- Name: COLUMN cg_user_substitution.substed_subject_title; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substed_subject_title IS 'Должность из сертификата/УХ пользователя, которого замещают';


--
-- Name: COLUMN cg_user_substitution.substing_subject_cn; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substing_subject_cn IS 'CN(ФИО) из сертификата/УХ пользователя, который замещает ';


--
-- Name: COLUMN cg_user_substitution.substing_subject_org; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substing_subject_org IS 'Организация из сертификата/УХ пользователя, который замещает ';


--
-- Name: COLUMN cg_user_substitution.substing_subject_title; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.substing_subject_title IS 'Должность из сертификата/УХ пользователя, который замещает';


--
-- Name: COLUMN cg_user_substitution.start_valid_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.start_valid_date IS 'Дата начала действия замещения';


--
-- Name: COLUMN cg_user_substitution.end_valid_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.end_valid_date IS 'Дата окончания действия замещения';


--
-- Name: COLUMN cg_user_substitution.nullification_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.nullification_date IS 'Дата аннулирования действия замещения';


--
-- Name: COLUMN cg_user_substitution.nullification_cms_sign; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.nullification_cms_sign IS 'ЭЦП, подтверждающее аннулирование замещения';


--
-- Name: COLUMN cg_user_substitution.is_passable; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.is_passable IS 'Возможно ли передать замещение дальше по цепочке';


--
-- Name: COLUMN cg_user_substitution.prev_user_substit_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.prev_user_substit_id IS 'Ссылка на исходное замещение';


--
-- Name: COLUMN cg_user_substitution.description; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN cg_user_substitution.description IS 'Описание';


--
-- Name: city; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE city (
    cityname character varying(255),
    citycode character varying(8),
    areacode character varying(8)
);


ALTER TABLE city OWNER TO ufos;


--
-- Name: commontask; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE commontask (
    taskid numeric NOT NULL,
    version numeric,
    name character varying(255),
    enabled numeric,
    useparent numeric,
    usecalendar numeric,
    servername character varying(255),
    priority character varying(20)
);


ALTER TABLE commontask OWNER TO ufos;

--
-- Name: complex_role; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE complex_role (
    id numeric NOT NULL,
    active numeric NOT NULL,
    systemname character varying(20) NOT NULL,
    name character varying(255),
    globaldicid character varying(128) NOT NULL,
    version numeric DEFAULT 0 NOT NULL
);


ALTER TABLE complex_role OWNER TO ufos;


--
-- Name: corrupteddoc; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE corrupteddoc (
    docid numeric NOT NULL
);


ALTER TABLE corrupteddoc OWNER TO ufos;

--
-- Name: counter; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE counter (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    doctypeid numeric NOT NULL,
    orgid numeric,
    year numeric,
    month numeric,
    quarter numeric,
    week numeric,
    day numeric,
    fld1_value character varying(50),
    fld2_value character varying(50),
    fld3_value character varying(50),
    fld4_value character varying(50),
    fld5_value character varying(50),
    counter1 numeric DEFAULT 0,
    counter2 numeric,
    counter3 numeric,
    counter4 numeric,
    counter5 numeric,
    last_used date,
    counterfieldname character varying(255)
);


ALTER TABLE counter OWNER TO ufos;

--
-- Name: counterconfiguration; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE counterconfiguration (
    id numeric NOT NULL,
    version numeric,
    doctypeid numeric,
    fieldname1 character varying(50),
    fieldname2 character varying(50),
    fieldname3 character varying(50),
    fieldname4 character varying(50),
    fieldname5 character varying(50),
    startcounter numeric,
    step numeric,
    mask character varying(255),
    startcounter2 numeric,
    step2 numeric,
    startcounter3 numeric,
    step3 numeric,
    startcounter4 numeric,
    step4 numeric,
    startcounter5 numeric,
    step5 numeric,
    override_enabled numeric(1,0),
    counterfieldname character varying(255)
);


ALTER TABLE counterconfiguration OWNER TO ufos;

--
-- Name: cryptosettings; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cryptosettings (
    cryptotypeid numeric,
    propertyname character varying(255),
    propertyvalue character varying(255)
);


ALTER TABLE cryptosettings OWNER TO ufos;

--
-- Name: cryptotype; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE cryptotype (
    cryptotypeid numeric NOT NULL,
    version numeric,
    name character varying(255)
);


ALTER TABLE cryptotype OWNER TO ufos;


--
-- Name: dict; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE dict (
    dictid numeric NOT NULL,
    version numeric,
    globaldocid character varying(36),
    doctypeid numeric,
    doctypeversion character varying(50),
    docstateid numeric NOT NULL,
    checklevel numeric,
    createdate date,
    createusername character varying(255),
    createorgid numeric,
    createorgname character varying(2000),
    createorgsystemname character varying(255),
    createcomplexname character varying(255),
    lastmodifydate date,
    lastmodifyusername character varying(255),
    lastmodifycomplexname character varying(255),
    localrplversion numeric(19,0),
    outerrplcomplexid numeric(19,0),
    outerrplversion numeric(19,0) DEFAULT 0,
    priority numeric,
    hasattaches boolean,
    localrpltimestamp timestamp(6) without time zone,
    archive numeric(4,0) DEFAULT 0 NOT NULL,
    has_attaches boolean DEFAULT false,
    attaches_size numeric(20,0) DEFAULT 0,
    attach_count numeric(5,0) DEFAULT 0,
    visibilityscope numeric DEFAULT 0 NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    deletedasroot boolean DEFAULT false NOT NULL,
    children_count numeric(4,0),
    leaf_count numeric(4,0),
    CONSTRAINT ch_dict_guidcase CHECK (((globaldocid)::text = lower((globaldocid)::text)))
);


ALTER TABLE dict OWNER TO ufos;

--
-- Name: dict_log; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE dict_log (
    dictname character varying(255),
    guid character varying(128),
    actiontime timestamp(6) without time zone,
    generation numeric,
    id numeric NOT NULL
);


ALTER TABLE dict_log OWNER TO ufos;

--
-- Name: dict_type; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE dict_type (
    id numeric NOT NULL,
    name character varying(255) NOT NULL,
    systemname character varying(255) NOT NULL,
    isdocumentary numeric DEFAULT 0 NOT NULL,
    islogenabled numeric DEFAULT 0 NOT NULL
);


ALTER TABLE dict_type OWNER TO ufos;


--
-- Name: dictchangelog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE dictchangelog (
    id numeric(19,0) NOT NULL,
    version numeric NOT NULL,
    logdate timestamp(6) without time zone NOT NULL,
    dictid numeric NOT NULL,
    complexname character varying(255) NOT NULL,
    username character varying(255) NOT NULL
);


ALTER TABLE dictchangelog OWNER TO ufos;


--
-- Name: dictfieldchangelog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE dictfieldchangelog (
    id numeric(19,0) NOT NULL,
    version numeric NOT NULL,
    dictchangelogid numeric(19,0) NOT NULL,
    fieldtype character varying(16) NOT NULL,
    fieldname character varying(255) NOT NULL,
    newvalue character varying(4000)
);


ALTER TABLE dictfieldchangelog OWNER TO ufos;


--
-- Name: doc; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc (
    docid numeric NOT NULL,
    version numeric,
    globaldocid character varying(36),
    doctypeid numeric,
    doctypeversion character varying(50),
    docstateid numeric NOT NULL,
    approvalstate numeric,
    checklevel numeric,
    destorgid numeric,
    createdate date,
    createusername character varying(255),
    createorgid numeric,
    createorgname character varying(2000),
    createorgsystemname character varying(255),
    createcomplexname character varying(255),
    lastmodifydate date,
    lastmodifyusername character varying(255),
    lastmodifycomplexname character varying(255),
    instatenumber numeric,
    priority numeric,
    accesslevel numeric(1,0),
    hasattaches numeric(1,0),
    attaches_size numeric(20,0) DEFAULT 0,
    attach_count numeric(6,0) DEFAULT 0,
    has_attaches boolean,
    sign_count numeric(7,0) DEFAULT 0,
    docstate_version numeric DEFAULT 0 NOT NULL,
    CONSTRAINT ch_doc_guidcase CHECK (((globaldocid)::text = lower((globaldocid)::text)))
);


ALTER TABLE doc OWNER TO ufos;

--
-- Name: doc_filter_condition; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_filter_condition (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    fieldname character varying(255) NOT NULL,
    fieldclassname character varying(255) NOT NULL,
    operatorstring character varying(255) NOT NULL,
    valuestring character varying(255) NOT NULL
);


ALTER TABLE doc_filter_condition OWNER TO ufos;

--
-- Name: doc_filter_condition_group; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_filter_condition_group (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL
);


ALTER TABLE doc_filter_condition_group OWNER TO ufos;

--
-- Name: doc_filter_group_conditions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_filter_group_conditions (
    group_id numeric NOT NULL,
    list_index numeric NOT NULL,
    condition_id numeric NOT NULL
);


ALTER TABLE doc_filter_group_conditions OWNER TO ufos;

--
-- Name: doc_filter_groups; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_filter_groups (
    filter_id numeric NOT NULL,
    list_index numeric NOT NULL,
    group_id numeric NOT NULL
);


ALTER TABLE doc_filter_groups OWNER TO ufos;

--
-- Name: doc_filters; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_filters (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    userid numeric,
    name character varying(255)
);


ALTER TABLE doc_filters OWNER TO ufos;

--
-- Name: doc_operations; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_operations (
    operation_id numeric NOT NULL,
    filtering_result_set numeric(1,0)
);


ALTER TABLE doc_operations OWNER TO ufos;

--
-- Name: doc_transport_history; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doc_transport_history (
    id numeric NOT NULL,
    doc_id numeric NOT NULL,
    ordinal numeric NOT NULL,
    record_time timestamp(6) without time zone DEFAULT NULL::timestamp without time zone NOT NULL,
    complex_glob_id character varying(255) NOT NULL,
    org_sys_name character varying(255),
    meta text,
    complex_name character varying(255) NOT NULL,
    org_name character varying(2000),
    event_type character varying(100) NOT NULL
);


ALTER TABLE doc_transport_history OWNER TO ufos;

--
-- Name: docchangelog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docchangelog (
    id numeric(19,0) NOT NULL,
    version numeric NOT NULL,
    logdate timestamp(6) without time zone NOT NULL,
    routecontextid numeric NOT NULL,
    complexname character varying(255) NOT NULL,
    username character varying(255) NOT NULL
);


ALTER TABLE docchangelog OWNER TO ufos;

--
-- Name: doccontent_advsigncomplete; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doccontent_advsigncomplete (
    version numeric,
    docid numeric NOT NULL,
    object_id numeric,
    err_message character varying(4000),
    completed boolean,
    prev_doc_guid character varying(128),
    object_type character varying(800)
);


ALTER TABLE doccontent_advsigncomplete OWNER TO ufos;

--
-- Name: doccontent_cancdoc; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doccontent_cancdoc (
    docid numeric NOT NULL,
    version numeric,
    addinfoid numeric,
    addinfo2id numeric,
    organizationid numeric,
    senderid numeric,
    receiverid numeric,
    cancdocid character varying(36),
    cancreason character varying(2000),
    statetransfer character varying(3),
    stateconfirm character varying(3),
    pbscode character varying(10),
    grbscode character varying(3),
    simpnum character varying(4),
    currpbs character varying(10),
    regnumber character varying(10)
);


ALTER TABLE doccontent_cancdoc OWNER TO ufos;

--
-- Name: doccontent_crlreqres; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doccontent_crlreqres (
    version numeric,
    docid numeric NOT NULL,
    this_update timestamp(6) without time zone,
    err_message character varying(4000),
    prev_doc_guid character varying(128),
    completed boolean
);


ALTER TABLE doccontent_crlreqres OWNER TO ufos;

--
-- Name: doccontent_rep; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doccontent_rep (
    version numeric,
    docid numeric NOT NULL,
    senderid numeric,
    receiverid numeric,
    addinfoid numeric,
    repdate date,
    reptype character varying(50),
    reptitle character varying(2000),
    param character varying(2000),
    repcreatedate date,
    versionformatdata character varying(50),
    versionformatpattern character varying(50),
    qpattern boolean,
    qdoc boolean,
    lasterrorcode character varying(50),
    lasterrormessage character varying(2000),
    formname character varying(2000),
    createdate date,
    executor character varying(240),
    contour character varying(1),
    sourcetype character varying(240),
    sourcecode character varying(240),
    sourcename character varying(240),
    receivertype character varying(240),
    receivercode character varying(240),
    receivername character varying(1440),
    period character varying(240),
    documenttype character varying(3),
    doctypename character varying(2000),
    financialyear character varying(4),
    recipientguid character varying(36),
    sourceguid character varying(36),
    typeofrecipient character varying(240),
    parameter12 character varying(150),
    intermediate character varying(1),
    docnumberdigits numeric,
    account character varying(150)
);


ALTER TABLE doccontent_rep OWNER TO ufos;

--
-- Name: doccontent_rep_service_request; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doccontent_rep_service_request (
    version numeric,
    docid numeric NOT NULL,
    senderid numeric,
    receiverid numeric,
    addinfoid numeric,
    requesttypecode character varying(15),
    objectcode character varying(15),
    errorid character varying(15),
    errorinfo character varying(2000),
    errordata character varying(2000),
    errordate date,
    doc_id character varying(15),
    transportstate character varying(160),
    transportstatecode character varying(3)
);


ALTER TABLE doccontent_rep_service_request OWNER TO ufos;


--
-- Name: docfieldchangelog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docfieldchangelog (
    id numeric(19,0) NOT NULL,
    version numeric NOT NULL,
    docchangelogid numeric(19,0) NOT NULL,
    fieldtype character varying(16) NOT NULL,
    fieldname character varying(255) NOT NULL,
    newvalue character varying(4000)
);


ALTER TABLE docfieldchangelog OWNER TO ufos;

--
-- Name: docfilling; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docfilling (
    fillingid numeric NOT NULL,
    version numeric,
    doctypeid numeric,
    orgid numeric,
    keyname character varying(255),
    fieldname character varying(255),
    fieldvalue character varying(255),
    useforcreate numeric,
    useforcopy numeric,
    useforpattern numeric
);


ALTER TABLE docfilling OWNER TO ufos;

--
-- Name: docfillingdependency; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docfillingdependency (
    dependonid numeric NOT NULL,
    dependfromid numeric NOT NULL
);


ALTER TABLE docfillingdependency OWNER TO ufos;

--
-- Name: doclifecyclevisedactions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doclifecyclevisedactions (
    doclifecycleid numeric NOT NULL,
    visedactionid numeric NOT NULL
);


ALTER TABLE doclifecyclevisedactions OWNER TO ufos;

--
-- Name: doclink; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doclink (
    id numeric NOT NULL,
    version numeric,
    link_type_id numeric,
    source_guid character varying(36),
    source_type_dict boolean,
    destination_guid character varying(36),
    destination_type_dict boolean,
    creation_date date,
    visible boolean,
    read_only boolean,
    bp_id character varying(255),
    bp_name character varying(255),
    author_name character varying(255),
    author_user_name character varying(255)
);


ALTER TABLE doclink OWNER TO ufos;

--
-- Name: docservice; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docservice (
    docserviceid numeric NOT NULL,
    version numeric,
    systemname character varying(255),
    name character varying(255)
);


ALTER TABLE docservice OWNER TO ufos;

--
-- Name: docservice_operations; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docservice_operations (
    operation_id numeric NOT NULL,
    docserviceid numeric NOT NULL
);


ALTER TABLE docservice_operations OWNER TO ufos;

--
-- Name: docstate; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docstate (
    docstateid numeric NOT NULL,
    version numeric,
    systemname character varying(255),
    name character varying(255),
    description character varying(255)
);


ALTER TABLE docstate OWNER TO ufos;

--
-- Name: docstatelog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE docstatelog (
    eventid numeric NOT NULL,
    eventdate date,
    docid numeric,
    oldstateid numeric,
    newstateid numeric,
    userid numeric
);


ALTER TABLE docstatelog OWNER TO ufos;

--
-- Name: doctype; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doctype (
    doctypeid numeric NOT NULL,
    version numeric,
    systemname character varying(255),
    name character varying(255),
    docserviceid numeric NOT NULL,
    visible boolean DEFAULT false,
    currentversion character varying(50),
    dictionary boolean DEFAULT false,
    journal_required boolean DEFAULT true,
    cert_key_usage_oid character varying(100),
    multisendrecipientscount numeric DEFAULT 5 NOT NULL,
    parentdoctypeid numeric,
    abstract boolean DEFAULT false,
    historyenable boolean DEFAULT false,
    lifecyclename character varying(255)
);


ALTER TABLE doctype OWNER TO ufos;


--
-- Name: doctypeid_change; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE doctypeid_change (
    systemname character varying(255),
    old_doctypeid numeric,
    new_doctypeid numeric,
    change_time timestamp(6) without time zone
);


ALTER TABLE doctypeid_change OWNER TO ufos;

--
-- Name: document_queue_to_org; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE document_queue_to_org (
    document_guid character varying(255) NOT NULL,
    org_id numeric(19,0) NOT NULL
);


ALTER TABLE document_queue_to_org OWNER TO ufos;

--
-- Name: drill_down_log; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE drill_down_log (
    id numeric NOT NULL,
    doc_id numeric NOT NULL,
    blob_content bytea
);


ALTER TABLE drill_down_log OWNER TO ufos;


--
-- Name: encloseddoc; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE encloseddoc (
    docid numeric NOT NULL,
    parentdocid numeric,
    enclosenum numeric
);


ALTER TABLE encloseddoc OWNER TO ufos;

--
-- Name: exclusiveday; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE exclusiveday (
    exclusivedayid numeric NOT NULL,
    version numeric,
    name character varying(255),
    calendardate date,
    daytype numeric,
    timetable character varying(255)
);


ALTER TABLE exclusiveday OWNER TO ufos;


--
-- Name: fieldset_addinfo; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE fieldset_addinfo (
    fieldsetid numeric NOT NULL,
    budgetcode character varying(30),
    doctypecode character varying(10),
    securitymode numeric,
    businessstatecode character varying(10),
    businessstatename character varying(200),
    docanswer character varying(4000),
    parentdocnumber character varying(100),
    parentdocdate date,
    budgetname character varying(2000),
    doctypename character varying(100),
    securitymodename character varying(100),
    fd date,
    td date,
    docregnumber character varying(100),
    docregdate date,
    docinputdate date,
    docrecivedate date,
    transit numeric,
    ismultisend boolean,
    docnumber character varying(240),
    currentlevel character varying(20),
    highertofk character varying(20),
    segmentcode character varying(1),
    doctofkcode character varying(10),
    contour character varying(20),
    docguid character varying(36),
    parentdocguid character varying(36),
    docaccount character varying(4000),
    tradingday date,
    syncaccount character varying(35),
    protokol boolean
);


ALTER TABLE fieldset_addinfo OWNER TO ufos;


--
-- Name: global_notification; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE global_notification (
    id numeric NOT NULL,
    lastmodify date NOT NULL,
    fd date NOT NULL,
    td date,
    message character varying(4000) NOT NULL,
    requiredread character(1) DEFAULT 'N'::bpchar NOT NULL,
    CONSTRAINT global_notification_chk1 CHECK ((requiredread = ANY (ARRAY['N'::bpchar, 'Y'::bpchar])))
);


ALTER TABLE global_notification OWNER TO ufos;



--
-- Name: groupcounterconfiguration; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE groupcounterconfiguration (
    id numeric NOT NULL,
    counterid numeric NOT NULL,
    version numeric,
    group_index numeric(1,0),
    organization character varying(1),
    year character varying(1),
    quarter character varying(1),
    month character varying(1),
    week character varying(1),
    day character varying(1),
    fieldname1 boolean,
    fieldname2 boolean,
    fieldname3 boolean,
    fieldname4 boolean,
    fieldname5 boolean,
    counter1 character varying(1),
    counter2 character varying(1),
    counter3 character varying(1),
    counter4 character varying(1)
);


ALTER TABLE groupcounterconfiguration OWNER TO ufos;

--
-- Name: hibernate_sequence; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE hibernate_sequence
    START WITH 3011210
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 4000;


ALTER TABLE hibernate_sequence OWNER TO ufos;

--
-- Name: hilosequences; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE hilosequences (
    sequencename character varying(50) NOT NULL,
    highvalues numeric
);


ALTER TABLE hilosequences OWNER TO ufos;

--
-- Name: history; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE history (
    id numeric NOT NULL,
    version numeric,
    username character varying(255),
    changedate date,
    globaldocid character varying(36)
);


ALTER TABLE history OWNER TO ufos;

--
-- Name: historyattributes; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE historyattributes (
    id numeric NOT NULL,
    checklevel numeric,
    lastmodifydate date,
    lastmodifyusername character varying(255),
    lastmodifycomplexname character varying(255),
    destorg character varying(255),
    lastprintdate date,
    printed character varying(1),
    approvalstate numeric(38,0),
    priority numeric,
    archive numeric(4,0),
    exportstatus character varying(32),
    hasattaches numeric(1,0),
    attachcount numeric(6,0),
    totalattachsize numeric(20,0),
    signcount numeric(7,0),
    docstate character varying(255),
    owner character varying(255),
    localdocstate character varying(255)
);


ALTER TABLE historyattributes OWNER TO ufos;

--
-- Name: historydoclog; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE historydoclog (
    eventid numeric NOT NULL,
    name character varying(255),
    eventdate date,
    docid numeric,
    oldstateid numeric,
    newstateid numeric,
    userid numeric
);


ALTER TABLE historydoclog OWNER TO ufos;

--
-- Name: historydoclogdetail; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE historydoclogdetail (
    eventid numeric,
    infoname character varying(255),
    infovalue character varying(255)
);


ALTER TABLE historydoclogdetail OWNER TO ufos;

--
-- Name: historyextension; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE historyextension (
    id numeric NOT NULL,
    attachment character varying(256),
    signature character varying(256)
);


ALTER TABLE historyextension OWNER TO ufos;


--
-- Name: jms_messages; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE jms_messages (
    messageid numeric NOT NULL,
    destination character varying(255) NOT NULL,
    txid numeric,
    txop character(1),
    messageblob bytea
);


ALTER TABLE jms_messages OWNER TO ufos;

--
-- Name: jms_roles; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE jms_roles (
    roleid character varying(32) NOT NULL,
    userid character varying(32) NOT NULL
);


ALTER TABLE jms_roles OWNER TO ufos;

--
-- Name: jms_subscriptions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE jms_subscriptions (
    clientid character varying(128) NOT NULL,
    subname character varying(128) NOT NULL,
    topic character varying(255),
    selector character varying(255)
);


ALTER TABLE jms_subscriptions OWNER TO ufos;

--
-- Name: jms_transactions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE jms_transactions (
    txid numeric NOT NULL
);


ALTER TABLE jms_transactions OWNER TO ufos;

--
-- Name: jms_users; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE jms_users (
    userid character varying(32) NOT NULL,
    passwd character varying(32),
    clientid character varying(128)
);


ALTER TABLE jms_users OWNER TO ufos;


CREATE TABLE linktype (
    id numeric NOT NULL,
    version numeric,
    name character varying(255) NOT NULL,
    systemname character varying(255) NOT NULL,
    inwardname character varying(255) NOT NULL,
    outwardname character varying(255) NOT NULL,
    directed boolean DEFAULT false,
    inicon bytea,
    outicon bytea,
    is_visible boolean DEFAULT true,
    visible_by_default numeric DEFAULT 0,
    inwarddelpolicy character varying(20),
    outwarddelpolicy character varying(20),
    read_only boolean DEFAULT false
);


ALTER TABLE linktype OWNER TO ufos;

--
-- Name: localcomplex; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE localcomplex (
    localcomplexid numeric NOT NULL,
    version numeric,
    systemname character varying(255),
    name character varying(255)
);


ALTER TABLE localcomplex OWNER TO ufos;

--
-- Name: log_clear_queue; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE log_clear_queue (
    id numeric(21,0) NOT NULL,
    mdate date,
    msg character varying(150)
);


ALTER TABLE log_clear_queue OWNER TO ufos;

--
-- Name: log_disabledfiscalevent; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE log_disabledfiscalevent (
    doctypesystemname character varying(255) NOT NULL,
    eventsystemname character varying(50) NOT NULL
);


ALTER TABLE log_disabledfiscalevent OWNER TO ufos;

--
-- Name: log_docevent; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE log_docevent (
    id numeric NOT NULL,
    systemname character varying(50) NOT NULL,
    name character varying(500)
);


ALTER TABLE log_docevent OWNER TO ufos;

--
-- Name: log_fiscaljournal; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE log_fiscaljournal (
    eventid numeric NOT NULL,
    creationdate timestamp(6) without time zone NOT NULL,
    eventstartdate date NOT NULL,
    eventfinishdate date NOT NULL,
    eventtypeid numeric NOT NULL,
    docid numeric NOT NULL,
    docguid character varying(36) NOT NULL,
    doctypeid numeric NOT NULL,
    orgsystemname character varying(255),
    usersystemname character varying(255),
    info character varying(255),
    docstateid numeric NOT NULL,
    complexglobalid character varying(255) NOT NULL,
    remoteaddressip character varying(15) NOT NULL,
    sessionid character varying(128) NOT NULL,
    details text
);


ALTER TABLE log_fiscaljournal OWNER TO ufos;


--
-- Name: oebs_docs_seq; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE oebs_docs_seq
    START WITH 40015
    INCREMENT BY 1
    MINVALUE 0
    NO MAXVALUE
    CACHE 1;


ALTER TABLE oebs_docs_seq OWNER TO ufos;


--
-- Name: operations; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE operations (
    operation_id numeric NOT NULL,
    system_name character varying(255) NOT NULL,
    name character varying(255)
);


ALTER TABLE operations OWNER TO ufos;

--
-- Name: org; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE org (
    orgid numeric NOT NULL,
    version numeric,
    systemname character varying(255),
    name character varying(2000),
    externalsystemid character varying(255),
    locked boolean DEFAULT false,
    thickclient boolean DEFAULT false,
    webclient boolean DEFAULT false,
    phoneclient boolean DEFAULT false,
    localclient boolean DEFAULT false,
    remotecomplexid numeric,
    orggroupid numeric,
    orgdataid numeric,
    globaldicid character varying(128) NOT NULL,
    last_update_date timestamp(6) without time zone DEFAULT NULL::timestamp without time zone,
    is_archive character(1) NOT NULL,
    username character varying(255),
    parentid numeric,
    CONSTRAINT ck_org_globaldicid CHECK (((globaldicid)::text = lower((globaldicid)::text)))
);


ALTER TABLE org OWNER TO ufos;

--
-- Name: orgcontacts; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE orgcontacts (
    orgcontactsid numeric NOT NULL,
    version numeric,
    managername character varying(60),
    managerphones character varying(40),
    accountantname character varying(60),
    accountantphones character varying(40),
    faxnumber character varying(40),
    email character varying(60)
);


ALTER TABLE orgcontacts OWNER TO ufos;

--
-- Name: orgdata; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE orgdata (
    orgdataid numeric NOT NULL,
    version numeric,
    financialname character varying(160),
    fullname character varying(255),
    internationalname character varying(140),
    statecode character varying(2),
    inn character varying(12),
    kpp character varying(9),
    okpo character varying(30),
    bic character varying(9),
    notes character varying(255),
    legaladdressid numeric,
    internationaladdressid numeric,
    orgcontactsid numeric,
    orgtypeid numeric,
    globaldicid character varying(128) NOT NULL
);


ALTER TABLE orgdata OWNER TO ufos;

--
-- Name: orgdocserviceexclude; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE orgdocserviceexclude (
    orgid numeric NOT NULL,
    docserviceid numeric NOT NULL
);


ALTER TABLE orgdocserviceexclude OWNER TO ufos;

--
-- Name: orgdoctypeexclude; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE orgdoctypeexclude (
    orgid numeric NOT NULL,
    doctypeid numeric NOT NULL
);


ALTER TABLE orgdoctypeexclude OWNER TO ufos;

CREATE TABLE orgtype (
    orgtypeid numeric NOT NULL,
    name character varying(255),
    description character varying(255),
    bydefault numeric DEFAULT 0
);


ALTER TABLE orgtype OWNER TO ufos;


--
-- Name: pref_node; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE pref_node (
    id numeric(19,0) NOT NULL,
    parent_id numeric(19,0),
    name character varying(80) NOT NULL,
    username character varying(255),
    created timestamp(6) without time zone NOT NULL
);


ALTER TABLE pref_node OWNER TO ufos;


--
-- Name: postaladdress; Type: TABLE; Schema: arm_offline; Owner: arm_offline; Tablespace:
--

CREATE TABLE postaladdress (
    postaladdressid numeric NOT NULL,
    version numeric,
    address character varying(255),
    area character varying(60),
    city character varying(60),
    country character varying(255),
    zip character varying(10)
);


ALTER TABLE postaladdress OWNER TO arm_offline;

--
-- Name: pref_property; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE pref_property (
    id numeric(19,0) NOT NULL,
    node_id numeric(19,0) NOT NULL,
    name character varying(80) NOT NULL,
    value character varying(4000),
    created timestamp(6) without time zone NOT NULL,
    modified timestamp(6) without time zone NOT NULL,
    bigvalue text
);


ALTER TABLE pref_property OWNER TO ufos;

--
-- Name: profilecryptosettings; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE profilecryptosettings (
    profileid numeric,
    propertyname character varying(255),
    propertyvalue character varying(255)
);


ALTER TABLE profilecryptosettings OWNER TO ufos;


--
-- Name: queue_document; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_document (
    guid character varying(255) NOT NULL,
    contentobjectguid character varying(255) NOT NULL,
    priority numeric(19,2) NOT NULL,
    resend_count numeric(10,0) NOT NULL,
    queue_item bytea,
    contentclassname character varying(1024),
    create_org_sys_name character varying(255),
    item_status character varying(255),
    creation_date timestamp(6) without time zone NOT NULL,
    direction character varying(255),
    error_message text,
    change_status_date timestamp(6) without time zone,
    errorcode character varying(32),
    target_complex_type character varying(50),
    is_system_transit boolean NOT NULL,
    doctype_name character varying(255),
    doc_log_parentdoc_guid character varying(255),
    doc_log_version numeric(10,0) DEFAULT NULL::numeric,
    blob_size numeric(19,0),
    CONSTRAINT ck_queue_document_coguid CHECK (((contentobjectguid)::text = lower((contentobjectguid)::text)))
);


ALTER TABLE queue_document OWNER TO ufos;

--
-- Name: queue_document_in_ids; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_document_in_ids (
    id numeric NOT NULL,
    guid character varying(36) NOT NULL
);


ALTER TABLE queue_document_in_ids OWNER TO ufos;

--
-- Name: queue_document_out_ids; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_document_out_ids (
    id numeric NOT NULL,
    guid character varying(36) NOT NULL
);


ALTER TABLE queue_document_out_ids OWNER TO ufos;

--
-- Name: queue_in_pack2docq; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_in_pack2docq (
    in_packet_id numeric(19,0) NOT NULL,
    docqueue_id character varying(255) NOT NULL
);


ALTER TABLE queue_in_pack2docq OWNER TO ufos;

--
-- Name: queue_multi_part_packet_in; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_multi_part_packet_in (
    id numeric(19,0) NOT NULL,
    filename character varying(255),
    receivedate timestamp(6) without time zone,
    seqguid character varying(255),
    seqnum numeric(10,0),
    seqsize numeric(10,0),
    file_size numeric(19,0),
    blobcontent bytea,
    errormessage text,
    status character varying(255),
    complextype character varying(255),
    parent_id numeric(19,0),
    exported boolean DEFAULT false NOT NULL,
    errorcode character varying(32),
    change_status_date timestamp(6) without time zone DEFAULT now() NOT NULL,
    priority numeric DEFAULT 50 NOT NULL,
    processcount numeric(3,0) DEFAULT 0 NOT NULL,
    obtained_through character varying(255)
);


ALTER TABLE queue_multi_part_packet_in OWNER TO ufos;

--
-- Name: queue_out_pack2docq; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_out_pack2docq (
    out_packet_id numeric(19,0) NOT NULL,
    docqueue_id character varying(255) NOT NULL
);


ALTER TABLE queue_out_pack2docq OWNER TO ufos;

--
-- Name: queue_packet_in; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_packet_in (
    id numeric(19,0) NOT NULL,
    filename character varying(255),
    receivedate timestamp(6) without time zone,
    seqguid character varying(255),
    file_size numeric(19,0),
    blobcontent bytea,
    errormessage text,
    status character varying(255),
    complextype character varying(255),
    exported boolean DEFAULT false NOT NULL,
    errorcode character varying(32),
    change_status_date timestamp(6) without time zone DEFAULT now() NOT NULL,
    priority numeric DEFAULT 50 NOT NULL,
    processcount numeric(3,0) DEFAULT 0 NOT NULL,
    owner_docs_count numeric(19,0),
    obtained_through character varying(255)
);


ALTER TABLE queue_packet_in OWNER TO ufos;

--
-- Name: queue_packet_in_ids; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_packet_in_ids (
    id numeric NOT NULL,
    packetid numeric NOT NULL
);


ALTER TABLE queue_packet_in_ids OWNER TO ufos;

--
-- Name: queue_packet_in_seq_guids; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_packet_in_seq_guids (
    seqguid character varying(255) NOT NULL
);


ALTER TABLE queue_packet_in_seq_guids OWNER TO ufos;

--
-- Name: queue_packet_out; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_packet_out (
    id numeric(19,0) NOT NULL,
    url character varying(4000),
    createdate timestamp(6) without time zone,
    seqnum numeric(10,0),
    sequencesize numeric(10,0),
    guid character varying(255),
    seqguid character varying(255),
    file_size numeric(10,0),
    contentclassname character varying(255),
    blobcontent bytea,
    status character varying(255),
    errormessage text,
    errorcode character varying(32),
    to_complex_id character varying(255),
    change_status_date timestamp(6) without time zone DEFAULT now() NOT NULL,
    priority numeric DEFAULT 50 NOT NULL,
    owner_docs_count numeric(19,0),
    processcount numeric(3,0) DEFAULT 0 NOT NULL
);


ALTER TABLE queue_packet_out OWNER TO ufos;

--
-- Name: queue_packet_out_ids; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_packet_out_ids (
    id numeric NOT NULL,
    packetid numeric NOT NULL
);


ALTER TABLE queue_packet_out_ids OWNER TO ufos;

--
-- Name: queue_search_index; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE queue_search_index (
    id numeric NOT NULL,
    guid character varying(36) NOT NULL,
    creation_date date NOT NULL,
    modify_date date,
    status numeric(1,0) NOT NULL,
    group_guid character varying(36)
);


ALTER TABLE queue_search_index OWNER TO ufos;


--
-- Name: routecontext; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE routecontext (
    routecontextid numeric NOT NULL,
    version numeric,
    docid numeric,
    localdocstateid numeric NOT NULL,
    ownerid numeric,
    lastprintdate date,
    printed boolean DEFAULT false,
    received boolean DEFAULT false,
    orgid numeric,
    archive numeric(4,0) DEFAULT 0 NOT NULL,
    exportstatus character varying(32),
    doctypeid numeric DEFAULT (-1) NOT NULL,
    docstateid numeric DEFAULT (-1) NOT NULL,
    deleted boolean DEFAULT false NOT NULL,
    docstate_version numeric DEFAULT 0 NOT NULL
);


ALTER TABLE routecontext OWNER TO ufos;

--
-- Name: rpl_object; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE rpl_object (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    active numeric(1,0) DEFAULT 1 NOT NULL,
    name character varying(255) NOT NULL,
    dicttypeid numeric
);


ALTER TABLE rpl_object OWNER TO ufos;

--
-- Name: rpl_receiver; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE rpl_receiver (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    active numeric(1,0) DEFAULT 1 NOT NULL,
    complexid numeric NOT NULL,
    is_records_filtration_active character(1) DEFAULT 'N'::bpchar NOT NULL,
    CONSTRAINT ch_rpl_receiver_is_recfilt_y_n CHECK ((is_records_filtration_active = ANY (ARRAY['N'::bpchar, 'Y'::bpchar])))
);


ALTER TABLE rpl_receiver OWNER TO ufos;

--
-- Name: rpl_receiver_subscription; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE rpl_receiver_subscription (
    rpl_receiver_id numeric NOT NULL,
    rpl_subscription_id numeric NOT NULL
);


ALTER TABLE rpl_receiver_subscription OWNER TO ufos;

--
-- Name: rpl_sent_object; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE rpl_sent_object (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    complexid numeric NOT NULL,
    localrplversion numeric(19,0) DEFAULT 0,
    dicttypeid numeric,
    send_date date
);


ALTER TABLE rpl_sent_object OWNER TO ufos;

--
-- Name: rpl_subscription; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE rpl_subscription (
    id numeric NOT NULL,
    version numeric DEFAULT 0 NOT NULL,
    active numeric(1,0) DEFAULT 1 NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE rpl_subscription OWNER TO ufos;

--
-- Name: rpl_subscription_object; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE rpl_subscription_object (
    rpl_subscription_id numeric NOT NULL,
    rpl_object_id numeric NOT NULL
);


ALTER TABLE rpl_subscription_object OWNER TO ufos;

--
-- Name: rplversion_sequence; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE rplversion_sequence
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE rplversion_sequence OWNER TO ufos;

--
-- Name: schema_version; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE schema_version (
    version_rank numeric NOT NULL,
    installed_rank numeric NOT NULL,
    version character varying(50) NOT NULL,
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum numeric,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp(6) without time zone DEFAULT now() NOT NULL,
    execution_time numeric NOT NULL,
    success numeric(1,0) NOT NULL
);


ALTER TABLE schema_version OWNER TO ufos;

--
-- Name: securityfield; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE securityfield (
    id numeric NOT NULL,
    version numeric NOT NULL,
    doc_type_id numeric,
    doc_field_path character varying(255) NOT NULL
);


ALTER TABLE securityfield OWNER TO ufos;

--
-- Name: securityprofile; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE securityprofile (
    securityprofileid numeric NOT NULL,
    version numeric,
    name character varying(255),
    maxauthattempts numeric,
    allowchangepassword boolean,
    minpasswordlength numeric,
    passwordrequired boolean,
    requestpasswordchange boolean
);


ALTER TABLE securityprofile OWNER TO ufos;

--
-- Name: sq_attachment; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_attachment
    START WITH 100
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 200;


ALTER TABLE sq_attachment OWNER TO ufos;

--
-- Name: sq_counter; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_counter
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;


ALTER TABLE sq_counter OWNER TO ufos;

--
-- Name: sq_dict; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_dict
    START WITH 3006914
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 4000;


ALTER TABLE sq_dict OWNER TO ufos;

--
-- Name: sq_dictgeneration; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_dictgeneration
    START WITH 3221
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_dictgeneration OWNER TO ufos;

--
-- Name: sq_dicttffschemaversion_id; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_dicttffschemaversion_id
    START WITH 761
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 20;


ALTER TABLE sq_dicttffschemaversion_id OWNER TO ufos;

--
-- Name: sq_doc; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_doc
    START WITH 53002670
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 4000;


ALTER TABLE sq_doc OWNER TO ufos;

--
-- Name: sq_fiscallogrecord; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_fiscallogrecord
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 4000;


ALTER TABLE sq_fiscallogrecord OWNER TO ufos;

--
-- Name: sq_history; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_history
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;


ALTER TABLE sq_history OWNER TO ufos;

--
-- Name: sq_log_clear_queue; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_log_clear_queue
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_log_clear_queue OWNER TO ufos;

--
-- Name: sq_pref_node; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_pref_node
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_pref_node OWNER TO ufos;

--
-- Name: sq_pref_property; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_pref_property
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_pref_property OWNER TO ufos;

--
-- Name: sq_queue_document_in_ids; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_queue_document_in_ids
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 5000;


ALTER TABLE sq_queue_document_in_ids OWNER TO ufos;

--
-- Name: sq_queue_document_out_ids; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_queue_document_out_ids
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 5000;


ALTER TABLE sq_queue_document_out_ids OWNER TO ufos;

--
-- Name: sq_queue_packet_in_ids; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_queue_packet_in_ids
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 5000;


ALTER TABLE sq_queue_packet_in_ids OWNER TO ufos;

--
-- Name: sq_queue_packet_out_ids; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_queue_packet_out_ids
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 5000;


ALTER TABLE sq_queue_packet_out_ids OWNER TO ufos;

--
-- Name: sq_queue_search_index; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_queue_search_index
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_queue_search_index OWNER TO ufos;

--
-- Name: sq_routecontext; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_routecontext
    START WITH 3001483
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 4000;


ALTER TABLE sq_routecontext OWNER TO ufos;

--
-- Name: sq_tb_direction; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_tb_direction
    START WITH 21
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_tb_direction OWNER TO ufos;

--
-- Name: sq_tb_message; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_tb_message
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_tb_message OWNER TO ufos;

--
-- Name: sq_tb_message_big_attributes; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_tb_message_big_attributes
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_tb_message_big_attributes OWNER TO ufos;

--
-- Name: sq_vsdict; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE sq_vsdict
    START WITH 25
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE sq_vsdict OWNER TO ufos;

--
-- Name: standconnection; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE standconnection (
    host character varying(128) NOT NULL,
    port numeric,
    userdir character varying(256),
    dateinit date,
    unique_field character varying(1) DEFAULT 'X'::character varying
);


ALTER TABLE standconnection OWNER TO ufos;


--
-- Name: sys_const_group; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE sys_const_group (
    groupid numeric NOT NULL,
    name character varying(255),
    userinfoid numeric NOT NULL,
    beanname character varying(256)
);


ALTER TABLE sys_const_group OWNER TO ufos;

--
-- Name: system_const; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE system_const (
    id numeric NOT NULL,
    name character varying(500) NOT NULL,
    value character varying(2000),
    version numeric DEFAULT 0 NOT NULL,
    orgid numeric,
    typeid numeric,
    userid numeric,
    prevvalue character varying(2000),
    username character varying(255),
    last_update_date timestamp(6) without time zone
);


ALTER TABLE system_const OWNER TO ufos;

--
-- Name: system_const_type; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE system_const_type (
    typeid numeric NOT NULL,
    name character varying(256),
    systemname character varying(256) NOT NULL,
    description character varying(1024),
    acceptedvalues character varying(2048),
    minvalue numeric DEFAULT 0,
    maxvalue numeric DEFAULT 0,
    defaultvalue character varying(1024),
    overridable boolean DEFAULT true
);


ALTER TABLE system_const_type OWNER TO ufos;

--
-- Name: system_formalized_journal; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE system_formalized_journal (
    id numeric(19,0),
    event_time timestamp(6) without time zone NOT NULL,
    subsystem_code character varying(10) NOT NULL,
    operation_code character varying(10) NOT NULL,
    operation_res character varying(1) NOT NULL,
    object_type character varying(10) NOT NULL,
    key_param character varying(100) NOT NULL,
    param_1 character varying(500),
    param_2 character varying(500),
    param_3 character varying(500),
    param_4 character varying(500),
    param_5 character varying(500),
    param_6 character varying(500),
    param_7 character varying(500),
    param_8 character varying(500),
    param_9 character varying(500),
    param_10 character varying(500),
    userid character varying(128),
    message character varying(2048)
);


ALTER TABLE system_formalized_journal OWNER TO ufos;

--
-- Name: t_complex; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE t_complex (
    id numeric(19,0) NOT NULL,
    local_id character varying(100) NOT NULL,
    global_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    parent_complex_id numeric(19,0),
    near_complex_id numeric(19,0),
    active_complex_address_id numeric(19,0),
    last_update_date timestamp(6) without time zone DEFAULT NULL::timestamp without time zone NOT NULL,
    is_home character(1) DEFAULT 'N'::bpchar NOT NULL,
    fingerprint character varying(60),
    complex_type character varying(50) NOT NULL,
    is_secret character varying(1) DEFAULT 'N'::character varying,
    is_archive character(1) NOT NULL,
    username character varying(255),
    is_offline character(1) DEFAULT 'N'::bpchar NOT NULL,
    CONSTRAINT ch_t_complex_is_home_31 CHECK ((is_home = ANY (ARRAY['Y'::bpchar, 'N'::bpchar]))),
    CONSTRAINT ch_t_complex_is_offline_yes_no CHECK ((is_offline = ANY (ARRAY['N'::bpchar, 'Y'::bpchar]))),
    CONSTRAINT is_secret_yes_no CHECK ((upper((is_secret)::text) = ANY (ARRAY['Y'::text, 'N'::text])))
);


ALTER TABLE t_complex OWNER TO ufos;

--
-- Name: t_complex_address; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE t_complex_address (
    id numeric(19,0) NOT NULL,
    digest character varying(255) NOT NULL,
    description character varying(2000),
    complex_id numeric(19,0),
    max_shipment_size numeric(10,0) NOT NULL,
    crypt_required character(1) DEFAULT 'N'::bpchar NOT NULL,
    protect_level character varying(20),
    crypto_key_template character varying(255),
    compress_content character varying(2) DEFAULT 'Y'::character varying,
    username character varying(255),
    last_update_date timestamp(6) without time zone DEFAULT NULL::timestamp without time zone,
    groups character varying(250)
);


ALTER TABLE t_complex_address OWNER TO ufos;


--
-- Name: t_security_fields; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE t_security_fields (
    id numeric(19,0) NOT NULL,
    shipment_id numeric(19,0),
    doc_field_path character varying(255),
    doc_field_type character varying(30),
    doc_field_value text
);


ALTER TABLE t_security_fields OWNER TO ufos;

--
-- Name: t_shipment_status; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE t_shipment_status (
    id numeric(19,0) NOT NULL,
    system_name character varying(30) NOT NULL,
    name character varying(30) NOT NULL
);


ALTER TABLE t_shipment_status OWNER TO ufos;

CREATE TABLE task (
    taskid numeric NOT NULL,
    javaclass character varying(255),
    config character varying(2000),
    parentid numeric,
    ordernumber numeric
);


ALTER TABLE task OWNER TO ufos;

--
-- Name: task_history; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE task_history (
    id numeric NOT NULL,
    created timestamp(6) without time zone NOT NULL,
    userid numeric NOT NULL,
    data text
);


ALTER TABLE task_history OWNER TO ufos;

--
-- Name: taskconditions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE taskconditions (
    scheduleid numeric NOT NULL,
    taskid numeric,
    name character varying(255),
    expression character varying(255)
);


ALTER TABLE taskconditions OWNER TO ufos;

--
-- Name: taskgroup; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE taskgroup (
    taskid numeric NOT NULL,
    parentid numeric,
    ordernumber numeric
);


ALTER TABLE taskgroup OWNER TO ufos;

--
-- Name: taskrestrictions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE taskrestrictions (
    scheduleid numeric NOT NULL,
    taskid numeric,
    name character varying(255),
    expression character varying(255)
);


ALTER TABLE taskrestrictions OWNER TO ufos;

--
-- Name: tb_direction; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE tb_direction (
    id numeric NOT NULL,
    code_of_system character varying(64) NOT NULL,
    name_of_system character varying(4000) NOT NULL,
    transport bytea
);


ALTER TABLE tb_direction OWNER TO ufos;

--
-- Name: tb_event; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE tb_event (
    event_id numeric NOT NULL,
    event_code character varying(10) NOT NULL,
    event_time date NOT NULL,
    error_msg character varying(4000),
    doc_guid character varying(36),
    doc_group character varying(3),
    doc_type character varying(3),
    r_number character varying(50),
    r_date date,
    e_number character varying(50),
    e_date date,
    msg_id numeric,
    msg_type character varying(1),
    message_status character varying(15),
    tb_msg_id numeric,
    bodid character varying(36),
    sufd_doc_guid character varying(36),
    transport_doc_guid character varying(36),
    transport_id character varying(150),
    add_info character varying(4000)
);


ALTER TABLE tb_event OWNER TO ufos;

--
-- Name: TABLE tb_event; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE tb_event IS 'Хранилище событий транспортного цикла документа';


--
-- Name: COLUMN tb_event.event_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.event_id IS 'Идентификатор события';


--
-- Name: COLUMN tb_event.event_code; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.event_code IS 'Код события';


--
-- Name: COLUMN tb_event.event_time; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.event_time IS 'Дата и время регистрации события';


--
-- Name: COLUMN tb_event.error_msg; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.error_msg IS 'Текст сообщения об ошибке';


--
-- Name: COLUMN tb_event.doc_guid; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.doc_guid IS 'GIUD документа';


--
-- Name: COLUMN tb_event.doc_group; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.doc_group IS 'Группа документа';


--
-- Name: COLUMN tb_event.doc_type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.doc_type IS 'Тип документа';


--
-- Name: COLUMN tb_event.r_number; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.r_number IS 'Регистрационный номер документа';


--
-- Name: COLUMN tb_event.r_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.r_date IS 'Дата регистрации документа';


--
-- Name: COLUMN tb_event.e_number; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.e_number IS 'Внешний номер документа';


--
-- Name: COLUMN tb_event.e_date; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.e_date IS 'Внешняя дата документа';


--
-- Name: COLUMN tb_event.msg_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.msg_id IS 'Идентификатор сообщения XML Брокера';


--
-- Name: COLUMN tb_event.msg_type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.msg_type IS 'Тип сообщения';


--
-- Name: COLUMN tb_event.message_status; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.message_status IS 'Статус сообщения';


--
-- Name: COLUMN tb_event.tb_msg_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.tb_msg_id IS 'Идентификатор сообщения в интеграционной таблице (tb_message)';


--
-- Name: COLUMN tb_event.bodid; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.bodid IS 'BODid сообщения СУФД';


--
-- Name: COLUMN tb_event.sufd_doc_guid; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.sufd_doc_guid IS 'GIUD документа СУФД';


--
-- Name: COLUMN tb_event.transport_doc_guid; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.transport_doc_guid IS 'GUID транспортного документа';


--
-- Name: COLUMN tb_event.transport_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.transport_id IS 'Идентификатор транспорта (имя/guid пакета, id/guid сообщения, имя файла)';


--
-- Name: COLUMN tb_event.add_info; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_event.add_info IS 'Дополнительная информация о событии';


--
-- Name: tb_event_s; Type: SEQUENCE; Schema: ufos; Owner: ufos
--

CREATE SEQUENCE tb_event_s
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 20;


ALTER TABLE tb_event_s OWNER TO ufos;

--
-- Name: tb_message; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE tb_message (
    id numeric NOT NULL,
    sys_from_code numeric NOT NULL,
    sys_to_code numeric NOT NULL,
    priority numeric NOT NULL,
    queue_name character varying(512) NOT NULL,
    time_create timestamp(6) without time zone NOT NULL,
    time_accept timestamp(6) without time zone NOT NULL,
    time_finish timestamp(6) without time zone NOT NULL,
    type_message character varying(512),
    desc_message character varying(4000) NOT NULL,
    status numeric NOT NULL,
    error_code character varying(64),
    error_text character varying(4000),
    xml bytea,
    time_last_processed timestamp(6) without time zone,
    processed_count numeric(2,0) DEFAULT 0 NOT NULL
);


ALTER TABLE tb_message OWNER TO ufos;

--
-- Name: tb_message_big_attributes; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE tb_message_big_attributes (
    tb_msg_id numeric NOT NULL,
    type character varying(3),
    name character varying(250),
    content_type character varying(250),
    description character varying(2000),
    body bytea,
    ordinal_number numeric(5,0),
    doc_guid character varying(36),
    id numeric(19,0) NOT NULL,
    att_guid character varying(36),
    prepared_date date,
    digital_signatures bytea
);


ALTER TABLE tb_message_big_attributes OWNER TO ufos;

--
-- Name: TABLE tb_message_big_attributes; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON TABLE tb_message_big_attributes IS 'Additional attributes to the message. Big, such as the attached files.';


--
-- Name: COLUMN tb_message_big_attributes.tb_msg_id; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.tb_msg_id IS 'The identifier of the message';


--
-- Name: COLUMN tb_message_big_attributes.type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.type IS 'Attribute type';


--
-- Name: COLUMN tb_message_big_attributes.name; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.name IS 'Name';


--
-- Name: COLUMN tb_message_big_attributes.content_type; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.content_type IS 'Content type';


--
-- Name: COLUMN tb_message_big_attributes.description; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.description IS 'Description';


--
-- Name: COLUMN tb_message_big_attributes.body; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.body IS 'Body';


--
-- Name: COLUMN tb_message_big_attributes.ordinal_number; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.ordinal_number IS 'Serial number';


--
-- Name: COLUMN tb_message_big_attributes.doc_guid; Type: COMMENT; Schema: ufos; Owner: ufos
--

COMMENT ON COLUMN tb_message_big_attributes.doc_guid IS 'Doc GUID';

--
-- Name: user_notification_recipients; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE user_notification_recipients (
    userid numeric,
    orgid numeric,
    notification_guid character varying(36)
);


ALTER TABLE user_notification_recipients OWNER TO ufos;

--
-- Name: user_notifications; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE user_notifications (
    guid character varying(36) NOT NULL,
    notification_date timestamp(6) without time zone,
    notification_type character varying(50),
    doctype character varying(255),
    docguid character varying(36)
);


ALTER TABLE user_notifications OWNER TO ufos;

--
-- Name: user_to_alert; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE user_to_alert (
    userinfoid numeric(21,0) NOT NULL,
    alertid numeric(21,0) NOT NULL
);


ALTER TABLE user_to_alert OWNER TO ufos;

--
-- Name: usercounterconfiguration; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE usercounterconfiguration (
    id numeric NOT NULL,
    version numeric,
    counterid numeric NOT NULL,
    orgid numeric,
    mask character varying(50)
);


ALTER TABLE usercounterconfiguration OWNER TO ufos;

--
-- Name: usergroup; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE usergroup (
    usergroupid numeric NOT NULL,
    version numeric,
    name character varying(255),
    systemname character varying(255),
    g_exclusive boolean DEFAULT false,
    system boolean DEFAULT false
);


ALTER TABLE usergroup OWNER TO ufos;

--
-- Name: usergroupmembers; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE usergroupmembers (
    usergroupid numeric NOT NULL,
    userinfoid numeric NOT NULL
);


ALTER TABLE usergroupmembers OWNER TO ufos;

--
-- Name: usergroupstoposition; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE usergroupstoposition (
    usergroupid numeric NOT NULL,
    docid numeric NOT NULL
);


ALTER TABLE usergroupstoposition OWNER TO ufos;

--
-- Name: userinfo; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE userinfo (
    userinfoid numeric NOT NULL,
    version numeric,
    systemname character varying(255),
    name character varying(255) NOT NULL,
    locale character varying(6),
    locked boolean DEFAULT false,
    userprofileid numeric,
    passwordhash bytea,
    salt bytea,
    userrequisitesid numeric,
    mustchangepassword boolean DEFAULT false,
    officeid numeric(2,0) DEFAULT 1,
    certauthorization boolean DEFAULT false,
    email character varying(50),
    externalsystemid character varying(2000),
    title character varying(100),
    department character varying(100)
);


ALTER TABLE userinfo OWNER TO ufos;

--
-- Name: userprofile; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE userprofile (
    userprofileid numeric NOT NULL,
    version numeric,
    name character varying(255),
    locale character varying(6),
    securityprofileid numeric
);


ALTER TABLE userprofile OWNER TO ufos;

--
-- Name: userrequisites; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE userrequisites (
    userrequisitesid numeric NOT NULL,
    version numeric,
    fio character varying(255),
    inn character varying(12),
    notes character varying(2000),
    iddocdata character varying(255),
    iddoctype character varying(255),
    physicaladdressid numeric,
    registrationaddressid numeric
);


ALTER TABLE userrequisites OWNER TO ufos;

--
-- Name: userstatistics; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE userstatistics (
    userstatisticsid numeric NOT NULL,
    userinfoid numeric,
    lastlogindate date
);


ALTER TABLE userstatistics OWNER TO ufos;

--
-- Name: usertoorg; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE usertoorg (
    userinfoid numeric,
    orgid numeric,
    list_index numeric NOT NULL
);


ALTER TABLE usertoorg OWNER TO ufos;

--
-- Name: usertoorg_audit_log; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE usertoorg_audit_log (
    id numeric NOT NULL,
    userinfoid numeric,
    orgid numeric,
    authoruserinfoid numeric,
    audit_date date
);


ALTER TABLE usertoorg_audit_log OWNER TO ufos;

--
-- Name: v_dq_in; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_in AS
 SELECT queue.guid,
    queue.contentobjectguid,
    queue.priority,
    queue.resend_count,
    queue.queue_item,
    queue.direction,
    queue.contentclassname,
    queue.errorcode,
    queue.error_message,
    queue.create_org_sys_name,
    queue.item_status,
    queue.creation_date,
    queue.change_status_date,
    queue.target_complex_type,
    queue.is_system_transit,
    queue.doctype_name,
    queue.doc_log_parentdoc_guid,
    queue.doc_log_version,
    queue.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'RECEIVED'::text) AND ((this_.direction)::text = 'IN'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_in_ids this__1))))) queue
  ORDER BY queue.priority;


ALTER TABLE v_dq_in OWNER TO postgres;

--
-- Name: v_dq_in_high; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_in_high AS
 SELECT queue_in_high.guid,
    queue_in_high.contentobjectguid,
    queue_in_high.priority,
    queue_in_high.resend_count,
    queue_in_high.queue_item,
    queue_in_high.direction,
    queue_in_high.contentclassname,
    queue_in_high.errorcode,
    queue_in_high.error_message,
    queue_in_high.create_org_sys_name,
    queue_in_high.item_status,
    queue_in_high.creation_date,
    queue_in_high.change_status_date,
    queue_in_high.target_complex_type,
    queue_in_high.is_system_transit,
    queue_in_high.doctype_name,
    queue_in_high.doc_log_parentdoc_guid,
    queue_in_high.doc_log_version,
    queue_in_high.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'RECEIVED_HIGH'::text) AND ((this_.direction)::text = 'IN'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_in_ids this__1))))) queue_in_high;


ALTER TABLE v_dq_in_high OWNER TO postgres;

--
-- Name: v_dq_in_low; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_in_low AS
 SELECT queue_in_low.guid,
    queue_in_low.contentobjectguid,
    queue_in_low.priority,
    queue_in_low.resend_count,
    queue_in_low.queue_item,
    queue_in_low.direction,
    queue_in_low.contentclassname,
    queue_in_low.errorcode,
    queue_in_low.error_message,
    queue_in_low.create_org_sys_name,
    queue_in_low.item_status,
    queue_in_low.creation_date,
    queue_in_low.change_status_date,
    queue_in_low.target_complex_type,
    queue_in_low.is_system_transit,
    queue_in_low.doctype_name,
    queue_in_low.doc_log_parentdoc_guid,
    queue_in_low.doc_log_version,
    queue_in_low.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'RECEIVED_LOW'::text) AND ((this_.direction)::text = 'IN'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_in_ids this__1))))) queue_in_low;


ALTER TABLE v_dq_in_low OWNER TO postgres;

--
-- Name: v_dq_in_normal; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_in_normal AS
 SELECT queue_in_normal.guid,
    queue_in_normal.contentobjectguid,
    queue_in_normal.priority,
    queue_in_normal.resend_count,
    queue_in_normal.queue_item,
    queue_in_normal.direction,
    queue_in_normal.contentclassname,
    queue_in_normal.errorcode,
    queue_in_normal.error_message,
    queue_in_normal.create_org_sys_name,
    queue_in_normal.item_status,
    queue_in_normal.creation_date,
    queue_in_normal.change_status_date,
    queue_in_normal.target_complex_type,
    queue_in_normal.is_system_transit,
    queue_in_normal.doctype_name,
    queue_in_normal.doc_log_parentdoc_guid,
    queue_in_normal.doc_log_version,
    queue_in_normal.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'RECEIVED'::text) AND ((this_.direction)::text = 'IN'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_in_ids this__1))))) queue_in_normal;


ALTER TABLE v_dq_in_normal OWNER TO postgres;

--
-- Name: v_dq_out; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_out AS
 SELECT queue.guid,
    queue.contentobjectguid,
    queue.priority,
    queue.resend_count,
    queue.queue_item,
    queue.direction,
    queue.contentclassname,
    queue.errorcode,
    queue.error_message,
    queue.create_org_sys_name,
    queue.item_status,
    queue.creation_date,
    queue.change_status_date,
    queue.target_complex_type,
    queue.is_system_transit,
    queue.doctype_name,
    queue.doc_log_parentdoc_guid,
    queue.doc_log_version,
    queue.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'SEND_READY'::text) AND ((this_.direction)::text = 'OUT'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_out_ids this__1))))) queue
  ORDER BY queue.priority;


ALTER TABLE v_dq_out OWNER TO postgres;

--
-- Name: v_dq_out_high; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_out_high AS
 SELECT queue_out_high.guid,
    queue_out_high.contentobjectguid,
    queue_out_high.priority,
    queue_out_high.resend_count,
    queue_out_high.queue_item,
    queue_out_high.direction,
    queue_out_high.contentclassname,
    queue_out_high.errorcode,
    queue_out_high.error_message,
    queue_out_high.create_org_sys_name,
    queue_out_high.item_status,
    queue_out_high.creation_date,
    queue_out_high.change_status_date,
    queue_out_high.target_complex_type,
    queue_out_high.is_system_transit,
    queue_out_high.doctype_name,
    queue_out_high.doc_log_parentdoc_guid,
    queue_out_high.doc_log_version,
    queue_out_high.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'SEND_READY_HIGH'::text) AND ((this_.direction)::text = 'OUT'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_out_ids this__1))))) queue_out_high;


ALTER TABLE v_dq_out_high OWNER TO postgres;

--
-- Name: v_dq_out_low; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_out_low AS
 SELECT queue_out_low.guid,
    queue_out_low.contentobjectguid,
    queue_out_low.priority,
    queue_out_low.resend_count,
    queue_out_low.queue_item,
    queue_out_low.direction,
    queue_out_low.contentclassname,
    queue_out_low.errorcode,
    queue_out_low.error_message,
    queue_out_low.create_org_sys_name,
    queue_out_low.item_status,
    queue_out_low.creation_date,
    queue_out_low.change_status_date,
    queue_out_low.target_complex_type,
    queue_out_low.is_system_transit,
    queue_out_low.doctype_name,
    queue_out_low.doc_log_parentdoc_guid,
    queue_out_low.doc_log_version,
    queue_out_low.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'SEND_READY_LOW'::text) AND ((this_.direction)::text = 'OUT'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_out_ids this__1))))) queue_out_low;


ALTER TABLE v_dq_out_low OWNER TO postgres;

--
-- Name: v_dq_out_normal; Type: VIEW; Schema: ufos; Owner: postgres
--

CREATE VIEW v_dq_out_normal AS
 SELECT queue_out_normal.guid,
    queue_out_normal.contentobjectguid,
    queue_out_normal.priority,
    queue_out_normal.resend_count,
    queue_out_normal.queue_item,
    queue_out_normal.direction,
    queue_out_normal.contentclassname,
    queue_out_normal.errorcode,
    queue_out_normal.error_message,
    queue_out_normal.create_org_sys_name,
    queue_out_normal.item_status,
    queue_out_normal.creation_date,
    queue_out_normal.change_status_date,
    queue_out_normal.target_complex_type,
    queue_out_normal.is_system_transit,
    queue_out_normal.doctype_name,
    queue_out_normal.doc_log_parentdoc_guid,
    queue_out_normal.doc_log_version,
    queue_out_normal.blob_size
   FROM ( SELECT this_.guid,
            this_.contentobjectguid,
            this_.priority,
            this_.resend_count,
            this_.queue_item,
            this_.direction,
            this_.contentclassname,
            this_.errorcode,
            this_.error_message,
            this_.create_org_sys_name,
            this_.item_status,
            this_.creation_date,
            this_.change_status_date,
            this_.target_complex_type,
            this_.is_system_transit,
            this_.doctype_name,
            this_.doc_log_parentdoc_guid,
            this_.doc_log_version,
            this_.blob_size
           FROM queue_document this_
          WHERE ((((this_.item_status)::text = 'SEND_READY'::text) AND ((this_.direction)::text = 'OUT'::text)) AND (NOT ((this_.guid)::text IN ( SELECT this__1.guid AS y0_
                   FROM queue_document_out_ids this__1))))) queue_out_normal;


ALTER TABLE v_dq_out_normal OWNER TO postgres;

--
-- Name: v_pq_in_high; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_in_high AS
 SELECT queue.id,
    queue.filename,
    queue.receivedate,
    queue.change_status_date,
    queue.processcount,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.blobcontent,
    queue.exported,
    queue.status,
    queue.complextype,
    queue.errorcode,
    queue.errormessage,
    queue.owner_docs_count,
    queue.obtained_through
   FROM ( SELECT this_.id,
            this_.filename,
            this_.receivedate,
            this_.change_status_date,
            this_.processcount,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.blobcontent,
            this_.exported,
            this_.status,
            this_.complextype,
            this_.errorcode,
            this_.errormessage,
            this_.owner_docs_count,
            this_.obtained_through
           FROM queue_packet_in this_
          WHERE (((this_.status)::text = 'RECEIVED_HIGH'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_in_ids this__1))))) queue;


ALTER TABLE v_pq_in_high OWNER TO ufos;

--
-- Name: v_pq_in_low; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_in_low AS
 SELECT queue.id,
    queue.filename,
    queue.receivedate,
    queue.change_status_date,
    queue.processcount,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.blobcontent,
    queue.exported,
    queue.status,
    queue.complextype,
    queue.errorcode,
    queue.errormessage,
    queue.owner_docs_count,
    queue.obtained_through
   FROM ( SELECT this_.id,
            this_.filename,
            this_.receivedate,
            this_.change_status_date,
            this_.processcount,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.blobcontent,
            this_.exported,
            this_.status,
            this_.complextype,
            this_.errorcode,
            this_.errormessage,
            this_.owner_docs_count,
            this_.obtained_through
           FROM queue_packet_in this_
          WHERE (((this_.status)::text = 'RECEIVED_LOW'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_in_ids this__1))))) queue;


ALTER TABLE v_pq_in_low OWNER TO ufos;

--
-- Name: v_pq_in_normal; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_in_normal AS
 SELECT queue.id,
    queue.filename,
    queue.receivedate,
    queue.change_status_date,
    queue.processcount,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.blobcontent,
    queue.exported,
    queue.status,
    queue.complextype,
    queue.errorcode,
    queue.errormessage,
    queue.owner_docs_count,
    queue.obtained_through
   FROM ( SELECT this_.id,
            this_.filename,
            this_.receivedate,
            this_.change_status_date,
            this_.processcount,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.blobcontent,
            this_.exported,
            this_.status,
            this_.complextype,
            this_.errorcode,
            this_.errormessage,
            this_.owner_docs_count,
            this_.obtained_through
           FROM queue_packet_in this_
          WHERE (((this_.status)::text = 'RECEIVED'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_in_ids this__1))))) queue;


ALTER TABLE v_pq_in_normal OWNER TO ufos;

--
-- Name: v_pq_out; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_out AS
 SELECT queue.id,
    queue.url,
    queue.createdate,
    queue.change_status_date,
    queue.seqnum,
    queue.sequencesize,
    queue.guid,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.contentclassname,
    queue.status,
    queue.blobcontent,
    queue.errorcode,
    queue.errormessage,
    queue.to_complex_id,
    queue.owner_docs_count
   FROM ( SELECT this_.id,
            this_.url,
            this_.createdate,
            this_.change_status_date,
            this_.seqnum,
            this_.sequencesize,
            this_.guid,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.contentclassname,
            this_.status,
            this_.blobcontent,
            this_.errorcode,
            this_.errormessage,
            this_.to_complex_id,
            this_.owner_docs_count
           FROM queue_packet_out this_
          WHERE (((this_.status)::text = 'SEND_READY'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_out_ids this__1))))) queue
  ORDER BY queue.priority, queue.createdate;


ALTER TABLE v_pq_out OWNER TO ufos;

--
-- Name: v_pq_out_high; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_out_high AS
 SELECT queue.id,
    queue.url,
    queue.createdate,
    queue.change_status_date,
    queue.seqnum,
    queue.sequencesize,
    queue.guid,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.contentclassname,
    queue.status,
    queue.blobcontent,
    queue.errorcode,
    queue.errormessage,
    queue.to_complex_id,
    queue.owner_docs_count
   FROM ( SELECT this_.id,
            this_.url,
            this_.createdate,
            this_.change_status_date,
            this_.seqnum,
            this_.sequencesize,
            this_.guid,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.contentclassname,
            this_.status,
            this_.blobcontent,
            this_.errorcode,
            this_.errormessage,
            this_.to_complex_id,
            this_.owner_docs_count
           FROM queue_packet_out this_
          WHERE (((this_.status)::text = 'SEND_READY_HIGH'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_out_ids this__1))))) queue;


ALTER TABLE v_pq_out_high OWNER TO ufos;

--
-- Name: v_pq_out_low; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_out_low AS
 SELECT queue.id,
    queue.url,
    queue.createdate,
    queue.change_status_date,
    queue.seqnum,
    queue.sequencesize,
    queue.guid,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.contentclassname,
    queue.status,
    queue.blobcontent,
    queue.errorcode,
    queue.errormessage,
    queue.to_complex_id,
    queue.owner_docs_count
   FROM ( SELECT this_.id,
            this_.url,
            this_.createdate,
            this_.change_status_date,
            this_.seqnum,
            this_.sequencesize,
            this_.guid,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.contentclassname,
            this_.status,
            this_.blobcontent,
            this_.errorcode,
            this_.errormessage,
            this_.to_complex_id,
            this_.owner_docs_count
           FROM queue_packet_out this_
          WHERE (((this_.status)::text = 'SEND_READY_LOW'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_out_ids this__1))))) queue;


ALTER TABLE v_pq_out_low OWNER TO ufos;

--
-- Name: v_pq_out_normal; Type: VIEW; Schema: ufos; Owner: ufos
--

CREATE VIEW v_pq_out_normal AS
 SELECT queue.id,
    queue.url,
    queue.createdate,
    queue.change_status_date,
    queue.seqnum,
    queue.sequencesize,
    queue.guid,
    queue.seqguid,
    queue.file_size,
    queue.priority,
    queue.contentclassname,
    queue.status,
    queue.blobcontent,
    queue.errorcode,
    queue.errormessage,
    queue.to_complex_id,
    queue.owner_docs_count
   FROM ( SELECT this_.id,
            this_.url,
            this_.createdate,
            this_.change_status_date,
            this_.seqnum,
            this_.sequencesize,
            this_.guid,
            this_.seqguid,
            this_.file_size,
            this_.priority,
            this_.contentclassname,
            this_.status,
            this_.blobcontent,
            this_.errorcode,
            this_.errormessage,
            this_.to_complex_id,
            this_.owner_docs_count
           FROM queue_packet_out this_
          WHERE (((this_.status)::text = 'SEND_READY'::text) AND (NOT (this_.id IN ( SELECT this__1.packetid AS y0_
                   FROM queue_packet_out_ids this__1))))) queue;


ALTER TABLE v_pq_out_normal OWNER TO ufos;

--
-- Name: valute; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE valute (
    dict_id numeric NOT NULL,
    valutecode character varying(3) NOT NULL,
    valutedesc character varying(255) NOT NULL
);


ALTER TABLE valute OWNER TO ufos;

--
-- Name: versions; Type: TABLE; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE TABLE versions (
    func_version character varying(30),
    core_version character varying(30),
    update_date date,
    sp character varying(50)
);


ALTER TABLE versions OWNER TO ufos;

--
-- Name: views_to_recreate; Type: TABLE; Schema: ufos; Owner: postgres; Tablespace: 
--

CREATE TABLE views_to_recreate (
    view_name name NOT NULL,
    view_definition text
);


ALTER TABLE views_to_recreate OWNER TO postgres;

--
-- Data for Name: admincontext; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY admincontext (contextid, version, name, defaultofficetypeid, defaultcomplextypeid, defaultorgtypeid, creditofficetypeid, creditcomplextypeid) FROM stdin;
1	0	Default	1	1	1	2	2
\.


--
-- Data for Name: adminservice; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY adminservice (adminserviceid, systemname, name, path_to_icon) FROM stdin;
14	link	Связи	/admin/16/link/link.png
1	userManagement	Управление клиентами	/admin/16/client/formalizejournal-tree-root.png
2	users	Пользователи	/admin/16/users/user_tree.png
3	systemConstants	Системные константы	/admin/16/sysconst/sysconst.png
4	settingsCryptography	Настройки криптографии	/admin/16/crypto/security_tree_root.png
5	categoriesOfDocuments	Категории документов	/admin/16/documenttype/category_tree_root.png
6	monitors	Мониторы	/admin/16/monitors/monitor_tree_root.png
7	rpl	Репликация	/admin/16/dictonaries/ico_dictionaries.png
8	journals	Журналы	/admin/16/journals/journal_tree_root.png
9	administrationComplex	Администрирование комплекса	/admin/16/admincomplex/complex_tree_root.png
10	transportation	Транспорт	/admin/16/transport/transport_tree_root.png
11	transportQueueMonitor	Монитор транспортной очереди	/admin/16/transport/transport_monitor_tree_root.png
12	reports	Отчёты	/admin/16/reports/reports.png
13	notifications	Уведомления	/admin/16/notifications/notifications.png
\.


--
-- Data for Name: adminsubmenu; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY adminsubmenu (adminsubmenuid, systemname, name, adminserviceid, path_to_icon, path_to_component, security_required, defaultvisible) FROM stdin;
45	linkType	Типы связи	14	/admin/16/link/link.png	/admin/link/linkType.zul	0	0
3003212	fileImportExtensions	Эскпортируемые расширения	9	/admin/16/admincomplex/export.png	/admin/admincomplex/fileImportExtensions.zul	0	0
67	cacheSettings	Настройки кэширования	9	/admin/16/admincomplex/cache.png	/admin/admincomplex/cacheSettings.zul	0	0
1	organisations	Организации	1	/admin/16/client/org_tree.png	/admin/client/organization.zul	0	0
6	post	Должности	2	/admin/16/users/title_tree.png	/admin/users/position.zul	0	0
3	orgAccounts	Учетные записи организации	2	/admin/16/users/user_tree.png	/admin/users/userModification.zul	1	0
5	userProfiles	Профили пользователей	2	/admin/16/users/userprofile_tree.png	/admin/users/userProfiles.zul	0	0
7	securityProfiles	Профили безопасности	2	/admin/16/users/securityprofile_tree.png	/admin/users/securityProfiles.zul	0	0
8	securityOperation	Операции безопасности	2	/admin/16/users/securityprofile_tree.png	/admin/users/securityOperation.zul	0	0
9	typeSysConst	Типы системных констант	3	/admin/16/sysconst/sysconst.png	/admin/constants/typeSysConst.zul	0	0
10	orgSysConst	Константы организаций	3	/admin/16/sysconst/const_org.png	/admin/constants/orgSysConst.zul	0	0
12	reqCert	Запрос на получение сертификата	4	/admin/16/crypto/key1.png	/admin/crypto/request/setting0.zul	0	1
13	userSignSubstitution	Передача прав подписи	4	/admin/16/crypto/user1_into.png	/admin/crypto/userSignSubstitution.zul	0	1
14	docTypes	Типы документов	5	/admin/16/documenttype/vised_action_tree.png	/admin/documenttype/docType.zul	0	0
15	activeUsersMonitors	Активные пользователи	6	/admin/16/monitors/userlog_tree.png	/admin/admincomplex/monitors/activeUsers.zul	0	0
16	autoprocMonitors	Автопроцедуры	6	/admin/16/monitors/autoproc_monitor.png	/admin/admincomplex/monitors/autoprocMonitor.zul	0	0
43	notificationList	Список уведомлений	13	/admin/16/notifications/notifications.png	/admin/notifications/notificationList.zul	0	0
41	treeSettings	Редактирование дерева	9	/admin/16/admincomplex/treenavigation.png	/admin/admincomplex/treeNavigation.zul	0	0
19	rplObjects	Репликационные объекты	7	/admin/16/dictonaries/books.png	/admin/admincomplex/rpl/rplObjects.zul	0	0
20	rplSubscription	Подписки	7	/admin/16/dictonaries/books.png	/admin/admincomplex/rpl/rplSubscription.zul	0	0
21	rplReceiver	Получатели	7	/admin/16/dictonaries/books.png	/admin/admincomplex/rpl/rplReceiver.zul	0	0
22	rplSentObject	Отправленные объекты	7	/admin/16/dictonaries/books.png	/admin/admincomplex/rpl/rplSentObject.zul	0	0
23	auditJournal	Журнал аудита	8	/admin/16/journals/auditjournal_tree.png	/admin/admincomplex/journal/auditJournal.zul	0	0
24	fiscalJournal	Фискальный журнал	8	/admin/16/journals/fiscaljournal_tree.png	/admin/admincomplex/journal/fiscalJournal.zul	0	0
25	formalizeJournal	Формализованный журнал	8	/admin/16/formalizejournal/journal.png	/admin/formalizejournal/formalizeJournal.zul	0	0
26	systemSettings	Настройки системы	9	/admin/16/admincomplex/configurations.png	/admin/admincomplex/systemConfiguration.zul	0	0
27	autoprocComplex	Автопроцедуры	9	/admin/16/admincomplex/scheduler_tree.png	/admin/admincomplex/autoproc/autoproc.zul	0	0
28	configureLogging	Настройки логирования	9	/admin/16/admincomplex/logging_tree.png	/admin/admincomplex/configureLogging.zul	0	0
29	servicesComplex	Услуги	9	/admin/16/admincomplex/cubes.png	/admin/admincomplex/services/services.zul	0	0
30	transConfiguration	Общие настройки	10	/admin/16/transport/tcpipservers_tree.png	/admin/transport/transpConfig.zul	0	0
31	transComplex	Транспортные комплексы	10	/admin/16/transport/tcpipservers_tree.png	/admin/transport/transComplex.zul	0	0
32	transAddress	Транспортные адреса	10	/admin/16/transport/tcpipservers_tree.png	/admin/transport/transAddress.zul	0	0
33	transBackOffice	Back Office	10	/admin/16/transport/tcpipservers_tree.png	/admin/transport/transBackOffice.zul	0	0
34	sufdMonitoring	Мониторинг СУФД	10	/admin/16/transport/tcpipservers_tree.png	/admin/transport/monitoring/sufdMonitoring.zul	0	0
35	backOfficeMonitoring	Мониторинг Back Office	10	/admin/16/transport/tcpipservers_tree.png	/admin/transport/backOfficeMonitoring.zul	0	0
36	queueTransMonitor	Пакетная очередь	11	/admin/16/transport/packets_queue.png	/admin/transport/packetQueueMonitor.zul	0	0
37	documentQueueTransMonitor	Документарная очередь	11	/admin/16/transport/documents_queue.png	/admin/transport/documentQueueMonitor.zul	0	0
2	accounts	Учетные записи	2	/admin/16/users/user_tree.png	/admin/users/accounts.zul	0	1
4	userGroups	Группы пользователей	2	/admin/16/users/usergroup_tree.png	/admin/users/userGroups.zul	0	0
40	reqQueue	Очередь отчётов	12	/admin/16/reports/reports.png	/admin/report/repQueue.zul	0	1
42	webSessionMonitor	Монитор web-сессий	6	/admin/16/monitors/userlog_tree.png	/admin/monitor/websessionmonitor.zul	0	0
44	notificationSettings	Системные уведомления	13	/admin/16/notifications/mail-message-icon.png	/admin/notifications/notificationSettings.zul	0	0
50	signSchemas	Схемы подписи документов	4	/admin/16/crypto/sign_scheme.png	/admin/crypto/signSchemas.zul	0	0
51	certificates	Сертификаты	4	/admin/16/crypto/certificates.png	/admin/crypto/certificate.zul	0	0
52	cryptoProfiles	Криптопрофили пользователей	4	/admin/16/crypto/users.png	/admin/crypto/cryptUserProfiles.zul	0	0
\.


--
-- Data for Name: alerts; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY alerts (alertid, systemname, name) FROM stdin;
0	FREE-SPACE-CHECKER	Проверка свободного места на диске
1	DB-FREE-SPACE-CHECKER	Проверка доступного места в табличных пространствах БД
2	EXTERNAL-SERVICES-CHECKER	Проверка доступности внешних служб
3	PACKET-SELECTION-TIMEOUT	Превышение времени выполнения запроса в транспортных очередях
\.


--
-- Data for Name: cg_algorithm; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_algorithm (id, name, description, type, version) FROM stdin;
1	1.2.643.2.2.3	Алгоритм подписи КриптоПро	SIGN	0
2	1.2.643.2.2.9	Алгоритм хеширования КриптоПро	HASH	0
3	1.2.643.2.2.21	Алгоритм шифрования КриптоПро	CHIPER	0
4	zip	\N	ARCH	0
\.


--
-- Data for Name: postaladdress; Type: TABLE DATA; Schema: arm_offline; Owner: arm_offline
--

COPY postaladdress (postaladdressid, version, address, area, city, country, zip) FROM stdin;
1	1	ул.Авиамоторная, 59А, стр.1	Московская	Москва	Россия	111024
2	1	Казанский пер., д.2/4	Московская	Москва	Россия	111049
3	1	Дегтярный пер.,д.5,стр.2	\N	Москва	\N	103050
4	1	Рязанский пр-т, д.30/15	\N	Москва	\N	109428
5	1	пр. Мира 70-А	Ямало-Ненецкий автономный округ	г.Ноябрьск	Россия	626802
\.


--
-- Data for Name: cg_attach_sign_info; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_attach_sign_info (id, attach_id) FROM stdin;
\.


--
-- Data for Name: cg_basecrl_update_info; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_basecrl_update_info (this_update, authority_key_id) FROM stdin;
\.


--
-- Data for Name: cg_cert_info; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_cert_info (id, fingerprint, is_4encrypt, is_4sign, name, revoked_date, is_temp, prev_cert_fingerprint, start_valid_date, end_valid_date, is_4data, subject_key_identifier, has_privatekey_link, version, authorization_usage, cert_bytes, userinfo_name) FROM stdin;
\.


--
-- Data for Name: cg_cert_j_doctype; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_cert_j_doctype (cert_info_id, doc_type_id) FROM stdin;
\.


--
-- Data for Name: cg_cert_j_substitution; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_cert_j_substitution (cert_info_id, user_substitution_id) FROM stdin;
\.


--
-- Data for Name: cg_csp_info; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_csp_info (id, provider_jclass, sign_algorithm_id, hash_algorithm_id, cipher_algorithm_id, is_active, is_win32, name, description, init_params, version) FROM stdin;
1	com.otr.cryptonew.jcaimpl.mcabridge.JCABridgeProvider	1	2	3	t	t	Crypto-Pro GOST R 34.10-2001 Cryptographic Service Provider	OTR-JCAMCA-BRIDGE	\N	0
\.


--
-- Data for Name: cg_da_assignment_org; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_assignment_org (id, version, org_hierarchy_id, name, org_guid, org_id, ext_type, user_assignment_id) FROM stdin;
\.


--
-- Data for Name: cg_da_doc; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_doc (id, doc_id, da_status, end_reason_id, version, da_doc_stage_id, da_init_user_id, da_force_user_id, da_force_sign_id, dt_start, dt_end, da_status_message, dt_force_date, da_process_id) FROM stdin;
\.


--
-- Data for Name: cg_da_doc_level_rule; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_doc_level_rule (id, doc_type_id, condition_type, condition, version, name) FROM stdin;
\.


--
-- Data for Name: cg_da_doc_org_rule; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_doc_org_rule (id, doc_type_id, name, description, version, condition_type, condition, org_dict_id) FROM stdin;
\.


--
-- Data for Name: cg_da_doc_stage; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_doc_stage (id, next_da_doc_stage_id, da_proc_stage_id, da_doc_id, dt_start, is_first, dt_end, version, delay, approve_type, stage_status) FROM stdin;
\.


--
-- Data for Name: cg_da_doc_stage_approver; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_doc_stage_approver (id, version, da_doc_stage_id, da_user_role_id, da_user_id, da_subst_user_id, da_sign_id, is_subst, approval_action, dt_complete) FROM stdin;
\.


--
-- Data for Name: cg_da_org_hierarchy; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_org_hierarchy (id, version, description, da_org_dict, title_field, pk_field, guid_field, parent_field, root_query, child_query, view_fields, view_titles) FROM stdin;
\.


--
-- Data for Name: cg_da_param; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_param (id, name, value) FROM stdin;
\.


--
-- Data for Name: cg_da_proc_result; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_proc_result (id, da_process_id, res_type, code, params, name, version) FROM stdin;
\.


--
-- Data for Name: cg_da_proc_stage; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_proc_stage (id, da_process_id, da_org_rule_id, da_min_level_rule_id, da_max_level_rule_id, position_id, name, description, version, exec_order, waiting_period, sign_type, is_random_user, da_role_id) FROM stdin;
\.


--
-- Data for Name: cg_da_process; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_process (id, name, description, dt_start, dt_end, doc_type_id, version, failure_result_id, success_result_id) FROM stdin;
\.


--
-- Data for Name: cg_da_role; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_role (id, name, descrption, active, version) FROM stdin;
\.


--
-- Data for Name: cg_da_role_item; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_role_item (id, da_role_id, doc_type_id, dt_start, dt_end, condition_type, condition, version) FROM stdin;
\.


--
-- Data for Name: cg_da_subst_user; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_subst_user (id, user_id, dt_subst_start, version, dt_subst_end) FROM stdin;
\.


--
-- Data for Name: cg_da_user_absence; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_user_absence (id, version, da_user_id, dt_start, dt_end, dt_register_date, da_register_user_id) FROM stdin;
\.


--
-- Data for Name: cg_da_user_assignment; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_user_assignment (id, user_id, subst_start, subst_end, position_id, version) FROM stdin;
\.


--
-- Data for Name: cg_da_user_assignment_role; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_user_assignment_role (id, da_role_id, dt_start, dt_end, approve_level, waiting_period, version, assignment_org_id) FROM stdin;
\.


--
-- Data for Name: cg_da_user_subst; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_da_user_subst (id, version, da_role_id, da_subst_user_id, dt_start, dt_end, da_reg_user_id, dt_register) FROM stdin;
\.


--
-- Data for Name: cg_doc_sign_info; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_doc_sign_info (id, sign_scheme_id, scheme_name, is_new_algorithm, docid) FROM stdin;
\.


--
-- Data for Name: cg_exserv_connection; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_exserv_connection (id, type, url, name, description, extra_params, last_date, last_error_code, last_err_mess, status, version, ca_fingerprint) FROM stdin;
2	TSP_SERVICE	http://192.168.6.132/PKISupport/tsa.dll	Тестовая ССМВ	Служба создания метки времени	\N	\N	\N	\N	READY	0	9b 95 50 5c 27 e2 ac c0 3b ab 76 91 fa 52 99 c6 52 ce 2c 50
1	OCSP_SERVICE	http://192.168.6.132/PKISupport/ocsp.dll	Тестовая СОПСС	Служба оперативной проверки статуса сертификата	\N	\N	\N	\N	READY	0	9b 95 50 5c 27 e2 ac c0 3b ab 76 91 fa 52 99 c6 52 ce 2c 50
\.


--
-- Data for Name: cg_process; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_process (docid, doctype, title) FROM stdin;
\.


--
-- Data for Name: cg_process_docs; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_process_docs (docid, doctype) FROM stdin;
\.


--
-- Data for Name: cg_process_doctypes; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_process_doctypes (doctype, doctable) FROM stdin;
BO_OBZ	DC_BO_OBZ
BO_OBF	DC_BO_OBF
BO_OBD	DC_BO_OBD
AGREEMENTDETAILS	DC_AGREEMENTDETAILS
AGREEMENTCHANGE	DC_AGREEMENTCHANGE
CANCDOC_REQ	DC_CANCDOC_REQ
SVBD_BVS	DC_SVBD_BVS
SPISTARGETSUBS	DC_SPISTARGETSUBS
NOTICE_SAP	DC_NOTICE_SAP
ZNV	DC_ZNV
NOTICE_OFFSET	DC_NOTICE_OFFSET
NOTIFTEST	DC_NOTIFTEST
ACTACCRATESADB	DC_ACTACCRATESADB
ACTACCRATESADBRG	DC_ACTADBRG
ITM	DC_ITM
RRI	DC_RRI
ZKR	DC_ZKR
ZKR_ZKC	DC_ZKR_ZKC
ZKR_ZNP	DC_ZKR_ZNP
ZNB	DC_ZNB
RKG	DC_RKG
PAY_COM	DC_PAY_COM
PayOrderPack	DC_PayOrderPack
ZRD	DC_ZRD
ACCRECVLIABSACT	DC_RECSENACT
ACTACCRATESBUDGET	DC_BUDACCACT
ACTACCRATESTGVF	DC_ACTACCRATESTGVF
DocRR	DC_DOCRR
REGEXPTABLE	DC_RRR
FOP	DC_FOP
ZIV	DC_ZIV
ZKR_ZSV	DC_ZKR_ZSV
ZPK	DC_ZPK
ACTACCRATESPBS	DC_ACTACCRATESPBS
RKF	DC_RKF
ACTACCRATESAIF	DC_ACTACCRATESAIFOUT
ACTACCRATESAIFPR	DC_ACTACCRATESAIFPROUT
OutgoingRAI	XXT_RP_HEADERS
OutgoingRI4	XXT_RP_HEADERS
ACTACCRATESSVR	DC_ACTACCRATESSVR
ACTACCRATESPBSP	DC_ACTACCRATESPBSP
NOTICE_CLIENT	DC_NOTICE_CLIENT
BO_OBT	DC_BO_OBT
UZT	DOCCONTENT_LETTER_TO_ORFK
\.


--
-- Data for Name: cg_process_ofk; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_process_ofk (orgid) FROM stdin;
\.


--
-- Data for Name: cg_protection_desc; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_protection_desc (id, cipher_algorithm_id, hash_algorithm_id, type, key_pattern, inset_flag, inset_length, inset_mask, change_date, active, version) FROM stdin;
1	3	2	MIN	\N	f	0	\N	2008-02-22 08:13:24	t	0
2	3	2	AVG	\N	f	0	\N	2008-02-22 08:13:25	t	0
\.


--
-- Data for Name: cg_sign_info; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_sign_info (id, cipher_algorithm_id, hash_algorithm_id, csp_info_id, cert_fingerprint, subject_cname, subject_title, subject_org, is_local, creation_date, is_advanced, adv_status, adv_error_code, adv_error_mess, last_check_status, last_check_date, version, guid, last_inspector_sysname, what_signed, subject_org_system_name, creation_login, sign_format, user_name, cms_signed_data, certifying_hash, signed_data) FROM stdin;
\.


--
-- Data for Name: cg_sign_scheme; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_sign_scheme (id, doc_type_id, name, description, content, active, version, guid, distributed, conditions, pattern_version, scheme_version, raw_content, start_date, start_date_default) FROM stdin;
\.


--
-- Data for Name: cg_sscheme_changing_track; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_sscheme_changing_track (id, sign_scheme_id, raw_content, content, record_date, version, userinfo_id) FROM stdin;
\.


--
-- Data for Name: cg_user_profile; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_user_profile (id, arch_algorithm_id, checksum_algorithm_id, userinfo_id, protection_level, usercert_fingerprint, protect_desc_min_id, protect_desc_av_id, version, formalized_title, name, userinfo_systemname) FROM stdin;
1	4	2	1	MIN	02 C6 2D 8C 64 72 48 D2 67 B5 9D 32 A4 9C D6 9B 5F 77 98 76	1	2	0	\N	Иванов Петр Дмитриевич	bear
\.


--
-- Data for Name: cg_user_substitution; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cg_user_substitution (id, substed_userinfo_id, substing_userinfo_id, substed_subject_cn, substed_subject_org, substed_subject_title, substing_subject_cn, substing_subject_org, substing_subject_title, start_valid_date, end_valid_date, nullification_date, nullification_cms_sign, is_passable, prev_user_substit_id, description, nullification_uhash_data, substed_userinfo_name, substing_userinfo_name) FROM stdin;
\.


--
-- Data for Name: complex_role; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY complex_role (id, active, systemname, name, globaldicid, version) FROM stdin;
10	0	CAFK	ЦАФК	890ffee5-bfce-485f-b103-f4d2eff6867b	0
20	1	UFK	УФК	b371a156-2339-410f-886e-c5bd7fd84652	0
30	0	OFK	ОФК	47fd5f3f-0617-490f-a3a6-4d683aefcb3f	0
40	0	GRBS	ГРБС	b9aaea18-7b0f-4692-9e26-be8caa16e78a	0
50	0	GRBSs	ГРБСс	7548ea37-3bfa-4f54-b7db-6a2f3afb16d5	0
60	0	RBS	РБС	37ef98af-0cc5-40a4-81db-f8a8f9317bfe	0
70	0	RBSs	РБСс	378936f2-16da-4ac7-a605-8d41040e3250	0
80	0	PBS	ПБС	6917ba4f-a7dd-4c54-9396-e92ab1026809	0
90	0	PBSs	ПБСс	580d0daf-b885-4d9d-8bf1-79391ea8b08a	0
100	0	FO	ФО	e4f974d7-acee-4fae-939f-baf1c2ce2cc2	0
110	0	AP	АП	1ddaf949-7041-48f6-afba-a25bd3ad9a03	0
120	0	TEST	Тест	63602aae-0bac-4c2b-be58-e553a8995eec	0
130	0	UFKs	УФКс	8106a7a2-438b-4c27-9c22-573610321228	0
140	0	OFKs	ОФКс	5a9b43b1-cbc6-4039-ba15-37aadf133b93	0
150	0	SSG	ПБС ТОАП	0b9c1886-8d69-4d87-8c1e-ca0db7983ee6	0
160	0	PR	Разные участники ЭОД	16e3c8ae-0bcc-3a99-e053-0401140a3923	0
\.


--
-- Data for Name: cryptosettings; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cryptosettings (cryptotypeid, propertyname, propertyvalue) FROM stdin;
1	CryptoProvider	SUN
1	SignAlgorithm	DSA
1	KeyStoreType	JKS
1	KeyStoreRef	sufd.keystore
1	KeyStorePassword	KSPassword
2	CryptoProvider	Crypto-Pro GOST R 34.10-2001 Cryptographic Service Provider
2	SignAlgorithm	1.2.643.2.2.3
2	KeyStoreType	MCAKeyStore
\.


--
-- Data for Name: cryptotype; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY cryptotype (cryptotypeid, version, name) FROM stdin;
1	0	SUN
2	0	CryptoPro CSP/2.0
\.

--
-- Data for Name: docstate; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY docstate (docstateid, version, systemname, name, description) FROM stdin;
1	0	CREATED	Черновик	Черновик
\.


--
-- Data for Name: docstatelog; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY docstatelog (eventid, eventdate, docid, oldstateid, newstateid, userid) FROM stdin;
\.



--
-- Name: hibernate_sequence; Type: SEQUENCE SET; Schema: ufos; Owner: ufos
--

SELECT pg_catalog.setval('hibernate_sequence', 3023209, true);


--
-- Data for Name: hilosequences; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY hilosequences (sequencename, highvalues) FROM stdin;
general	0
\.

--
-- Data for Name: log_docevent; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY log_docevent (id, systemname, name) FROM stdin;
1	NEW_DOC	Создание нового документа
2	EDIT_DOC	Редактирование документа
3	SAVE_DOC	Сохранение документа
4	IMPORT_DOC	Импорт документа
5	EXPORT_DOC	Экспорт документа
6	COPY_DOC	Копирование документа
7	ADD_SIGN	Документ подписан
8	CHANGE_DOCSTATE_START	Изменение статуса документа: начало
9	CHANGE_DOCSTATE_FINISH	Изменение статуса документа: окончание
10	RECEIVE_DOC_FROM_TRANSPORT	Загрузка документа из транспорта
11	PROCESS_INCOMING_DOC	Обработка входящего документа
12	SEND_DOC	Отправить документ в транспортную подсистему
13	CHECK_DOC	Документарный контроль
14	PREPARATION_TO_SEND	Подготовка документа к отправке
15	REFUSE_DOC	Отказать документ
16	REFUSE_DOC_BY_PROTOCOL	Отказать документ с созданием протокола
17	ADD_ATTACH	Добавление вложения
18	REMOVE_ATTACH	Удаление вложения
19	VERIFY_SIGN	Проверка подписи
20	REMOVE_SIGN	Удаление подписи
21	PRINT_DOC	Печать документа
22	DELETE_DOC	Удаление в корзину
23	SYS_WEB_PREPARE_DOC_SIGN	Подготовить документ к подписи в WEB
24	SYS_WEB_DOC_SIGN	Сформировать подпись и довести её до УЭП
25	ADD_ATTACH_SIGN	Вложение документа подписано
26	AUTO_EXPORT	Автоматический экспорт
27	AUTO_IMPORT	Автоматический импорт
28	CHANGE_DOC_VERSION	Изменение версии документа
29	AUTO_EXPORT_ERROR	Ошибка автоматического экспорта
30	REGISTER_DOC	Регистрация документа
3003064	REMOVE_DOC	Удаление документа
\.


--
-- Data for Name: operations; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY operations (operation_id, system_name, name) FROM stdin;
1	OP_DOC_READ	Операция "Чтение"
2	OP_DOC_PRINT	Операция "Печать"
3	OP_DOC_EDIT	Операция "Редактирование"
4	OP_DOC_DIGITAL_SIGNATURE	Операция "ЭЦП"
5	OP_DOC_SEND	Операция "Пересылка"
6	OP_DOC_REJECT	Операция "Отказ"
7	OP_DOC_IMPORT_EXPORT	Операция "Импорт/Экспорт"
8	OP_DOC_APPROVE	Операция "Утверждение"
9	OP_DOC_ADMIN_CHECK	Операция "Администрирование док. контроля"
10	OP_SYS_BASE	Операция "Базовая функциональность"
11	OP_SYS_ADMINISTRATION	Операция "Администрирование системы"
12	OP_SYS_SECURITY_ADMINISTRATION	Операция "Администрирование безопасности (защищаемых объектов)"
13	OP_SYS_CRIPTO_ADMINISTRATION	Операция "Администрирование криптозащиты"
14	OP_SYS_FORMALIZE_JOURNAL_READING	Операция "Просмотр формализованного журнала"
15	OP_SYS_SERVICES	Операция "Серверные службы"
16	OP_SYS_DUBP_USER_MANAGER	Управление пользователями ДУБП
17	OP_SYS_ORG_USERS_MANAGER	Управление пользователями внутри организации
18	OP_SYS_FALL_DOC_ACCESSLEVEL	Полномочие понижения уровня конфеденциальности документа
\.


--
-- Data for Name: org; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY org (orgid, version, systemname, name, externalsystemid, locked, thickclient, webclient, phoneclient, localclient, remotecomplexid, orggroupid, orgdataid, globaldicid, last_update_date, is_archive, username, parentid) FROM stdin;
1	21	1	xОФК по ... району г. ...	ОФК по ... району г. ...	f	f	f	f	t	1	\N	1	e830d00e-f054-466d-b016-0546e6977720	2015-05-26 14:54:23.444	N	system_user	\N
\.


--
-- Data for Name: orgcontacts; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY orgcontacts (orgcontactsid, version, managername, managerphones, accountantname, accountantphones, faxnumber, email) FROM stdin;
1	1	Иванов Петр Дмитриевич	+7(495)745-26-56	\N	\N	\N	\N
2	1	Петрова Людмила Львовна	\N	Петров Олег Анатольевич	\N	\N	\N
3	1	Савельев Олег Леонидович	\N	\N	\N	\N	\N
4	1	Кондратьев Дмитрий Владимирович	\N	\N	\N	\N	spros@nojabrsk.ru
\.


--
-- Data for Name: orgdata; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY orgdata (orgdataid, version, financialname, fullname, internationalname, statecode, inn, kpp, okpo, bic, notes, legaladdressid, internationaladdressid, orgcontactsid, orgtypeid, globaldicid) FROM stdin;
1	0	АКБ "СБС-АГРО" г.Москва	АКБ "СБС-АГРО" г.Москва	SBS-AGRO	\N	7701352236	770101001	1057700008684	044525056	\N	1	\N	1	1	4f406280-3d24-42db-8b42-a88999e05bf0
2	0	ООО "СвитЛайн"	Общество с ограниченной ответственностью "СвитЛайн"	SweetLine	01	7706270072	770601001	\N	\N	\N	2	\N	2	1	85b27665-a703-45ab-8795-630a5c890bfd
3	0	ОАО "СпецТрестДвигательмонтаж"	Открытое акционерное общество "СпецТрестДвигательмонтаж"	\N	02	7710268340	771001001	\N	\N	\N	3	\N	\N	1	0d10206b-7b08-4651-a548-55b8a95826ac
4	0	ЗАО "Инвестэлектросвязь"	Закрытое акционерное общество "Инвестэлектросвязь"	InvestElectroSvyaz	01	7729336178	\N	45028183	\N	\N	4	\N	3	1	4c8ff29a-952f-4c24-93bf-a04974e4215a
5	0	ОАО "Уралсвязьинформ"	Открытое Акционерное Общество "УралСвязьИнформ	Uralsvazinform	01	5902183094	890502001	0508818	\N	\N	5	\N	4	1	07e72f4f-4141-4dd1-9330-7e78f9714ddd
\.


--
-- Data for Name: orgdocserviceexclude; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY orgdocserviceexclude (orgid, docserviceid) FROM stdin;
\.


--
-- Data for Name: orgdoctypeexclude; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY orgdoctypeexclude (orgid, doctypeid) FROM stdin;
\.


--
-- Data for Name: orgtype; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY orgtype (orgtypeid, name, description, bydefault) FROM stdin;
1	Резидент	Организация - резидент РФ	-1
2	Нерезидент	Организация - нерезидент РФ	0
3	Резидент, КО	Организация - резидент РФ, кредитная организация	0
4	Нерезидент, КО	Организация - нерезидент РФ, кредитная организация	0
5	Резидент, РКО	Организация - резидент РФ, Расчетно-кассовое обслуживание	0
6	Нерезидент, РКО	Организация - нерезидент РФ, Расчетно-кассовое обслуживание	0
7	Физ. резидент	Физическое лицо - резидент РФ, счета	0
8	Физ. нерезидент	Физическое лицо - нерезидент РФ, счета	0
9	Карт. резидент	Физическое лицо - резидент РФ, пластиковые карты	0
10	Карт. нерезидент	Физическое лицо - нерезидент РФ, пластиковые карты	0
11	Физ. резидент, РКО	Физическое лицо - резидент РФ, Расчетно-кассовое обслуживание	0
12	Физ. нерезидент, РКО	ОФизическое лицо - нерезидент РФ, Расчетно-кассовое обслуживание	0
\.

--
-- Data for Name: schema_version; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY schema_version (version_rank, installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
128	128	8.21.0.0.0.007.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.007.0__patch.sql	-2144578153	ufos	2015-05-25 11:47:51.48948	18	1
129	129	8.21.0.0.0.008.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.008.0__patch.sql	-1875357521	ufos	2015-05-25 11:47:51.824024	294	1
130	130	8.21.0.0.0.009.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.009.0__patch.sql	1206647332	ufos	2015-05-25 11:47:51.978115	107	1
131	131	8.21.0.0.0.010.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.010.0__patch.sql	-1067396166	ufos	2015-05-25 11:47:52.068117	38	1
132	132	8.21.0.0.0.011.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.011.0__patch.sql	-772066520	ufos	2015-05-25 11:47:52.12566	6	1
159	133	8.22.0.0.0.001.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.001.0__patch.sql	940272260	ufos	2015-05-25 11:47:52.184907	7	1
160	134	8.22.0.0.0.002.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.002.0__patch.sql	-1067396166	ufos	2015-05-25 11:47:52.236138	3	1
161	135	8.22.0.0.0.003.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.003.0__patch.sql	-772066520	ufos	2015-05-25 11:47:52.282476	7	1
162	136	8.22.0.0.0.004.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.004.0__patch.sql	433158057	ufos	2015-05-25 11:47:54.31012	1994	1
163	137	8.22.0.0.0.005.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.005.0__patch.sql	-1168933111	ufos	2015-05-25 11:47:55.850131	1485	1
164	138	8.22.0.0.0.006.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.006.0__patch.sql	-1877219756	ufos	2015-05-25 11:47:55.956635	57	1
165	139	8.22.0.0.0.007.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.007.0__patch.sql	1161493775	ufos	2015-05-25 11:47:56.038325	38	1
166	140	8.22.0.0.0.008.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.008.0__patch.sql	1128670872	ufos	2015-05-25 11:47:56.159705	76	1
167	141	8.22.0.0.0.009.0	patch	SQL	/8.22.0/ufos.8.22.0.0.0.009.0__patch.sql	120183190	ufos	2015-05-25 11:47:56.597652	385	1
133	142	8.21.0.220.1.001.1	patch	SQL	/8.220.1/ufos.8.21.0.220.1.001.1__patch.sql	-1103904157	ufos	2015-05-26 11:45:16.643927	538	1
134	143	8.21.0.220.1.002.1	patch	SQL	/8.220.1/ufos.8.21.0.220.1.002.1__patch.sql	819467782	ufos	2015-05-26 11:45:17.027789	295	1
135	144	8.21.0.220.2.001.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.001.1__patch.sql	528251204	ufos	2015-05-26 11:45:17.670383	588	1
136	145	8.21.0.220.2.002.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.002.1__patch.sql	671464839	ufos	2015-05-26 11:45:18.525532	796	1
137	146	8.21.0.220.2.003.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.003.1__patch.sql	-696644448	ufos	2015-05-26 11:45:18.89167	320	1
138	147	8.21.0.220.2.004.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.004.1__patch.sql	341880374	ufos	2015-05-26 11:45:19.25761	304	1
140	149	8.21.0.220.2.006.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.006.1__patch.sql	456744068	ufos	2015-05-26 11:58:22.79118	24	1
141	150	8.21.0.220.2.007.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.007.1__patch.sql	778850059	ufos	2015-05-26 11:58:23.392555	538	1
142	151	8.21.0.220.2.008.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.008.1__patch.sql	1051970694	ufos	2015-05-26 11:58:23.465265	19	1
143	152	8.21.0.220.2.009.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.009.1__patch.sql	-1775341649	ufos	2015-05-26 11:58:23.716589	198	1
144	153	8.21.0.220.2.010.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.010.1__patch.sql	76913981	ufos	2015-05-26 11:58:23.900411	131	1
145	154	8.21.0.220.2.011.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.011.1__patch.sql	1682669893	ufos	2015-05-26 11:58:24.042003	77	1
146	155	8.21.0.220.2.012.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.012.1__patch.sql	-1149187072	ufos	2015-05-26 11:58:24.286203	187	1
147	156	8.21.0.220.2.013.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.013.1__patch.sql	1367382329	ufos	2015-05-26 11:58:24.357276	25	1
148	157	8.21.0.220.2.014.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.014.1__patch.sql	808976978	ufos	2015-05-26 11:58:24.465507	59	1
149	158	8.21.0.220.2.015.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.015.1__patch.sql	1372964016	ufos	2015-05-26 11:58:24.550207	22	1
150	159	8.21.0.220.2.016.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.016.1__patch.sql	-346421608	ufos	2015-05-26 11:58:24.626942	23	1
151	160	8.21.0.220.2.017.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.017.1__patch.sql	857370981	ufos	2015-05-26 11:58:24.750333	70	1
152	161	8.21.0.220.2.018.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.018.1__patch.sql	1280568667	ufos	2015-05-26 11:58:25.045865	238	1
153	162	8.21.0.220.2.019.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.019.1__patch.sql	-1894348454	ufos	2015-05-26 11:58:26.145438	1034	1
154	163	8.21.0.220.2.020.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.020.1__patch.sql	-1894132608	ufos	2015-05-26 11:58:28.166671	1957	1
155	164	8.21.0.220.2.021.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.021.1__patch.sql	-2099102008	ufos	2015-05-26 11:58:28.908321	678	1
156	165	8.21.0.220.2.022.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.022.1__patch.sql	-1748216544	ufos	2015-05-26 11:58:29.169977	197	1
157	166	8.21.0.220.2.023.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.023.1__patch.sql	-929302898	ufos	2015-05-26 11:58:29.468967	239	1
158	167	8.21.0.220.3.001.1	patch	SQL	/8.220.3/ufos.8.21.0.220.3.001.1__patch.sql	-2087397222	ufos	2015-05-26 11:58:29.944783	412	1
139	148	8.21.0.220.2.005.1	patch	SQL	/8.220.2/ufos.8.21.0.220.2.005.1__patch.sql	-1375189459	ufos	2015-05-26 11:55:49.62289	371	1
45	45	8.15.0.0.0.008.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.008.0__patch.sql	810329977	ufos	2015-05-25 11:47:39.105789	167	1
46	46	8.15.0.0.0.009.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.009.0__patch.sql	-1999123058	ufos	2015-05-25 11:47:39.403867	270	1
47	47	8.16.0.0.0.001.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.001.0__patch.sql	-1681933547	ufos	2015-05-25 11:47:39.445437	5	1
48	48	8.16.0.0.0.002.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.002.0__patch.sql	930731957	ufos	2015-05-25 11:47:39.506295	29	1
49	49	8.16.0.0.0.003.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.003.0__patch.sql	810329977	ufos	2015-05-25 11:47:39.537369	2	1
50	50	8.16.0.0.0.004.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.004.0__patch.sql	-23639037	ufos	2015-05-25 11:47:39.598244	29	1
51	51	8.16.0.0.0.005.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.005.0__patch.sql	-1999123058	ufos	2015-05-25 11:47:39.651683	25	1
52	52	8.16.0.0.0.006.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.006.0__patch.sql	-1051006214	ufos	2015-05-25 11:47:39.821904	145	1
53	53	8.16.0.0.0.007.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.007.0__patch.sql	1422913961	ufos	2015-05-25 11:47:39.922406	70	1
54	54	8.16.0.0.0.008.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.008.0__patch.sql	-900102061	ufos	2015-05-25 11:47:40.02249	70	1
55	55	8.16.0.0.0.009.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.009.0__patch.sql	-869807715	ufos	2015-05-25 11:47:40.123031	71	1
56	56	8.16.0.0.0.010.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.010.0__patch.sql	362530859	ufos	2015-05-25 11:47:40.298655	148	1
57	57	8.16.0.0.0.011.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.011.0__patch.sql	163879521	ufos	2015-05-25 11:47:40.369692	38	1
58	58	8.16.0.0.0.012.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.012.0__patch.sql	-1862941141	ufos	2015-05-25 11:47:41.764816	1361	1
59	59	8.16.0.0.0.013.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.013.0__patch.sql	1998909795	ufos	2015-05-25 11:47:41.866797	64	1
60	60	8.16.0.0.0.014.0	patch	SQL	/8.16.0/ufos.8.16.0.0.0.014.0__patch.sql	-1079724653	ufos	2015-05-25 11:47:42.049987	141	1
61	61	8.17.0.0.0.001.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.001.0__patch.sql	574906621	ufos	2015-05-25 11:47:42.102565	10	1
62	62	8.17.0.0.0.002.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.002.0__patch.sql	2038308261	ufos	2015-05-25 11:47:42.176399	38	1
63	63	8.17.0.0.0.003.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.003.0__patch.sql	1745158844	ufos	2015-05-25 11:47:42.361493	146	1
64	64	8.17.0.0.0.004.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.004.0__patch.sql	889645756	ufos	2015-05-25 11:47:43.018789	628	1
65	65	8.17.0.0.0.005.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.005.0__patch.sql	0	ufos	2015-05-25 11:47:43.061288	1	1
66	66	8.17.0.0.0.006.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.006.0__patch.sql	-762980071	ufos	2015-05-25 11:47:43.138452	39	1
67	67	8.17.0.0.0.007.0	patch	SQL	/8.17.0/ufos.8.17.0.0.0.007.0__patch.sql	1066040474	ufos	2015-05-25 11:47:43.194803	22	1
68	68	8.18.0.0.0.001.0	patch	SQL	/8.18.0/ufos.8.18.0.0.0.001.0__patch.sql	-1649982281	ufos	2015-05-25 11:47:43.247945	13	1
69	69	8.18.0.0.0.002.0	patch	SQL	/8.18.0/ufos.8.18.0.0.0.002.0__patch.sql	2027530100	ufos	2015-05-25 11:47:43.295576	15	1
70	70	8.18.0.0.0.003.0	patch	SQL	/8.18.0/ufos.8.18.0.0.0.003.0__patch.sql	-762464266	ufos	2015-05-25 11:47:43.495563	168	1
71	71	8.18.0.0.0.004.0	patch	SQL	/8.18.0/ufos.8.18.0.0.0.004.0__patch.sql	-577486783	ufos	2015-05-25 11:47:43.699243	171	1
72	72	8.18.0.0.0.005.0	patch	SQL	/8.18.0/ufos.8.18.0.0.0.005.0__patch.sql	-1458870940	ufos	2015-05-25 11:47:43.944935	206	1
73	73	8.18.0.0.0.006.0	patch	SQL	/8.18.0/ufos.8.18.0.0.0.006.0__patch.sql	-1835636312	ufos	2015-05-25 11:47:44.041184	61	1
74	74	8.19.0.0.0.001.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.001.0__patch.sql	-818448248	ufos	2015-05-25 11:47:44.082948	10	1
75	75	8.19.0.0.0.002.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.002.0__patch.sql	1970054385	ufos	2015-05-25 11:47:44.20778	89	1
76	76	8.19.0.0.0.003.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.003.0__patch.sql	-577486783	ufos	2015-05-25 11:47:44.32923	83	1
77	77	8.19.0.0.0.004.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.004.0__patch.sql	-1458870940	ufos	2015-05-25 11:47:44.375673	16	1
78	78	8.19.0.0.0.005.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.005.0__patch.sql	-2104235230	ufos	2015-05-25 11:47:44.416507	8	1
79	79	8.19.0.0.0.006.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.006.0__patch.sql	-1835636312	ufos	2015-05-25 11:47:44.534625	2	1
80	80	8.19.0.0.0.007.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.007.0__patch.sql	-968946300	ufos	2015-05-25 11:47:44.575713	11	1
81	81	8.19.0.0.0.008.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.008.0__patch.sql	1734403397	ufos	2015-05-25 11:47:44.654062	47	1
82	82	8.19.0.0.0.009.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.009.0__patch.sql	1684936030	ufos	2015-05-25 11:47:44.743865	61	1
83	83	8.19.0.0.0.010.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.010.0__patch.sql	1370247255	ufos	2015-05-25 11:47:44.836057	61	1
84	84	8.19.0.0.0.011.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.011.0__patch.sql	-1649973108	ufos	2015-05-25 11:47:44.993091	127	1
85	85	8.19.0.0.0.012.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.012.0__patch.sql	418514708	ufos	2015-05-25 11:47:45.152148	126	1
86	86	8.19.0.0.0.013.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.013.0__patch.sql	136191224	ufos	2015-05-25 11:47:45.196338	12	1
87	87	8.19.0.0.0.014.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.014.0__patch.sql	-233687671	ufos	2015-05-25 11:47:45.410734	186	1
88	88	8.19.0.0.0.015.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.015.0__patch.sql	-575905412	ufos	2015-05-25 11:47:45.586134	144	1
89	89	8.19.0.0.0.016.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.016.0__patch.sql	-1039918733	ufos	2015-05-25 11:47:45.627694	10	1
90	90	8.19.0.0.0.017.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.017.0__patch.sql	880993121	ufos	2015-05-25 11:47:45.728663	69	1
91	91	8.19.0.0.0.018.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.018.0__patch.sql	909889309	ufos	2015-05-25 11:47:45.854807	93	1
92	92	8.19.0.0.0.019.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.019.0__patch.sql	1332329659	ufos	2015-05-25 11:47:47.616756	1687	1
93	93	8.19.0.0.0.020.0	patch	SQL	/8.19.0/ufos.8.19.0.0.0.020.0__patch.sql	2015684147	ufos	2015-05-25 11:47:47.724959	76	1
94	94	8.20.0.0.0.001.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.001.0__patch.sql	-1869751531	ufos	2015-05-25 11:47:47.765824	9	1
95	95	8.20.0.0.0.002.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.002.0__patch.sql	1684936030	ufos	2015-05-25 11:47:47.803426	2	1
96	96	8.20.0.0.0.003.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.003.0__patch.sql	-2018370575	ufos	2015-05-25 11:47:47.9801	135	1
97	97	8.20.0.0.0.004.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.004.0__patch.sql	1370247255	ufos	2015-05-25 11:47:48.025246	2	1
98	98	8.20.0.0.0.005.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.005.0__patch.sql	-1649973108	ufos	2015-05-25 11:47:48.069883	4	1
99	99	8.20.0.0.0.006.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.006.0__patch.sql	418514708	ufos	2015-05-25 11:47:48.199213	83	1
100	100	8.20.0.0.0.007.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.007.0__patch.sql	136191224	ufos	2015-05-25 11:47:48.24416	10	1
101	101	8.20.0.0.0.008.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.008.0__patch.sql	427528427	ufos	2015-05-25 11:47:48.618014	331	1
102	102	8.20.0.0.0.009.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.009.0__patch.sql	-233687671	ufos	2015-05-25 11:47:48.653546	2	1
103	103	8.20.0.0.0.010.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.010.0__patch.sql	930203410	ufos	2015-05-25 11:47:48.717637	25	1
104	104	8.20.0.0.0.011.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.011.0__patch.sql	-2064669296	ufos	2015-05-25 11:47:48.818869	67	1
105	105	8.20.0.0.0.012.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.012.0__patch.sql	0	ufos	2015-05-25 11:47:48.852287	0	1
106	106	8.20.0.0.0.013.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.013.0__patch.sql	2512653	ufos	2015-05-25 11:47:49.072711	182	1
107	107	8.20.0.0.0.014.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.014.0__patch.sql	-382259598	ufos	2015-05-25 11:47:49.177297	62	1
1	1	1	Initial database	INIT	Initial database	\N	ufos	2015-05-25 11:31:01.377089	0	1
2	2	8.0.0.0.0.001.0	patch	SQL	/8.0.0/ufos.8.0.0.0.0.001.0__patch.sql	-2059227025	ufos	2015-05-25 11:31:03.265094	202	1
3	3	8.0.0.0.0.002.0	patch	SQL	/8.0.0/ufos.8.0.0.0.0.002.0__patch.sql	1992605221	ufos	2015-05-25 11:31:03.470707	179	1
4	4	8.0.0.0.0.003.0	patch	SQL	/8.0.0/ufos.8.0.0.0.0.003.0__patch.sql	2098969608	ufos	2015-05-25 11:31:03.601942	104	1
5	5	8.0.0.0.0.004.0	patch	SQL	/8.0.0/ufos.8.0.0.0.0.004.0__patch.sql	1919895353	ufos	2015-05-25 11:31:05.463694	1844	1
6	6	8.2.0.0.0.001.0	patch	SQL	/8.2.0/ufos.8.2.0.0.0.001.0__patch.sql	-441578999	ufos	2015-05-25 11:31:06.264307	785	1
7	7	8.5.0.0.0.001.0	patch	SQL	/8.5.0/ufos.8.5.0.0.0.001.0__patch.sql	1980462060	ufos	2015-05-25 11:31:07.827216	1536	1
8	8	8.6.0.0.0.001.0	patch	SQL	/8.6.0/ufos.8.6.0.0.0.001.0__patch.sql	-1250084024	ufos	2015-05-25 11:31:08.367005	514	1
9	9	8.7.0.0.0.001.0	patch	SQL	/8.7.0/ufos.8.7.0.0.0.001.0__patch.sql	-373279300	ufos	2015-05-25 11:31:08.391301	9	1
10	10	8.8.0.0.0.001.0	patch	SQL	/8.8.0/ufos.8.8.0.0.0.001.0__patch.sql	-477689233	ufos	2015-05-25 11:31:08.450823	44	1
11	11	8.8.0.0.0.002.0	patch	SQL	/8.8.0/ufos.8.8.0.0.0.002.0__patch.sql	-1007817155	ufos	2015-05-25 11:31:09.403642	935	1
12	12	8.9.0.0.0.001.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.001.0__patch.sql	78851529	ufos	2015-05-25 11:31:09.435296	7	1
13	13	8.9.0.0.0.002.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.002.0__patch.sql	292142630	ufos	2015-05-25 11:31:09.669435	216	1
14	14	8.9.0.0.0.003.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.003.0__patch.sql	1693700837	ufos	2015-05-25 11:31:09.739498	39	1
15	15	8.9.0.0.0.004.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.004.0__patch.sql	-1082834141	ufos	2015-05-25 11:31:14.643793	4860	1
16	16	8.9.0.0.0.005.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.005.0__patch.sql	1375606036	ufos	2015-05-25 11:31:14.788358	124	1
17	17	8.9.0.0.0.006.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.006.0__patch.sql	1490824797	ufos	2015-05-25 11:31:14.936124	120	1
18	18	8.9.0.0.0.007.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.007.0__patch.sql	-1679335892	ufos	2015-05-25 11:31:15.195064	234	1
19	19	8.9.0.0.0.008.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.008.0__patch.sql	-1403263707	ufos	2015-05-25 11:31:15.796722	560	1
20	20	8.9.0.0.0.009.0	patch	SQL	/8.9.0/ufos.8.9.0.0.0.009.0__patch.sql	-1651088780	ufos	2015-05-25 11:31:15.997868	177	1
21	21	8.10.0.0.0.001.0	patch	SQL	/8.10.0/ufos.8.10.0.0.0.001.0__patch.sql	-1186631705	ufos	2015-05-25 11:31:16.029757	6	1
22	22	8.10.0.0.0.002.0	patch	SQL	/8.10.0/ufos.8.10.0.0.0.002.0__patch.sql	-1651088780	ufos	2015-05-25 11:31:16.060433	2	1
23	23	8.11.0.0.0.001.0	patch	SQL	/8.11.0/ufos.8.11.0.0.0.001.0__patch.sql	12497935	ufos	2015-05-25 11:31:16.088525	7	1
24	24	8.11.0.0.0.002.0	patch	SQL	/8.11.0/ufos.8.11.0.0.0.002.0__patch.sql	853735321	ufos	2015-05-25 11:31:16.190666	69	1
25	25	8.11.0.0.0.003.0	patch	SQL	/8.11.0/ufos.8.11.0.0.0.003.0__patch.sql	417385365	ufos	2015-05-25 11:31:16.270757	49	1
26	26	8.12.0.0.0.001.0	patch	SQL	/8.12.0/ufos.8.12.0.0.0.001.0__patch.sql	-1119718299	ufos	2015-05-25 11:31:16.73836	444	1
27	27	8.12.0.0.0.002.0	patch	SQL	/8.12.0/ufos.8.12.0.0.0.002.0__patch.sql	866768524	ufos	2015-05-25 11:31:16.797787	32	1
28	28	8.12.0.0.0.003.0	patch	SQL	/8.12.0/ufos.8.12.0.0.0.003.0__patch.sql	829140868	ufos	2015-05-25 11:31:16.838696	15	1
29	29	8.13.0.0.0.001.0	patch	SQL	/8.13.0/ufos.8.13.0.0.0.001.0__patch.sql	-1472723554	ufos	2015-05-25 11:31:16.871818	6	1
30	30	8.13.0.0.0.002.0	patch	SQL	/8.13.0/ufos.8.13.0.0.0.002.0__patch.sql	866768524	ufos	2015-05-25 11:31:16.949823	50	1
31	31	8.13.0.0.0.003.0	patch	SQL	/8.13.0/ufos.8.13.0.0.0.003.0__patch.sql	1713576043	ufos	2015-05-25 11:31:17.059481	81	1
32	32	8.13.0.0.0.004.0	patch	SQL	/8.13.0/ufos.8.13.0.0.0.004.0__patch.sql	-531631984	ufos	2015-05-25 11:31:17.167761	75	1
33	33	8.13.0.0.0.005.0	patch	SQL	/8.13.0/ufos.8.13.0.0.0.005.0__patch.sql	962969585	ufos	2015-05-25 11:31:17.468235	273	1
34	34	8.14.0.0.0.001.0	patch	SQL	/8.14.0/ufos.8.14.0.0.0.001.0__patch.sql	859376260	ufos	2015-05-25 11:31:17.500432	5	1
35	35	8.14.0.0.0.002.0	patch	SQL	/8.14.0/ufos.8.14.0.0.0.002.0__patch.sql	-531631984	ufos	2015-05-25 11:31:17.529647	2	1
36	36	8.14.0.0.0.003.0	patch	SQL	/8.14.0/ufos.8.14.0.0.0.003.0__patch.sql	-1857606129	ufos	2015-05-25 11:31:17.562721	10	1
37	37	8.14.0.0.0.004.0	patch	SQL	/8.14.0/ufos.8.14.0.0.0.004.0__patch.sql	920531891	ufos	2015-05-25 11:31:17.653556	68	1
38	38	8.15.0.0.0.001.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.001.0__patch.sql	-1966943892	ufos	2015-05-25 11:31:17.683804	5	1
39	39	8.15.0.0.0.002.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.002.0__patch.sql	-1857606129	ufos	2015-05-25 11:31:17.713062	2	1
40	40	8.15.0.0.0.003.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.003.0__patch.sql	-1815649570	ufos	2015-05-25 11:31:17.759786	23	1
41	41	8.15.0.0.0.004.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.004.0__patch.sql	1179453927	ufos	2015-05-25 11:31:17.811138	23	1
42	42	8.15.0.0.0.005.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.005.0__patch.sql	726160479	ufos	2015-05-25 11:31:18.05506	215	1
43	43	8.15.0.0.0.006.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.006.0__patch.sql	920531891	ufos	2015-05-25 11:31:18.095376	3	1
44	44	8.15.0.0.0.007.0	patch	SQL	/8.15.0/ufos.8.15.0.0.0.007.0__patch.sql	-1348518057	ufos	2015-05-25 11:31:18.403571	272	1
108	108	8.20.0.0.0.015.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.015.0__patch.sql	880993121	ufos	2015-05-25 11:47:49.214852	2	1
109	109	8.20.0.0.0.016.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.016.0__patch.sql	115945425	ufos	2015-05-25 11:47:49.736659	486	1
110	110	8.20.0.0.0.017.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.017.0__patch.sql	1332329659	ufos	2015-05-25 11:47:49.811992	39	1
111	111	8.20.0.0.0.018.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.018.0__patch.sql	2015684147	ufos	2015-05-25 11:47:49.923081	78	1
112	112	8.20.0.0.0.019.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.019.0__patch.sql	-1443665496	ufos	2015-05-25 11:47:50.032863	78	1
113	113	8.20.0.0.0.020.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.020.0__patch.sql	-2113566360	ufos	2015-05-25 11:47:50.142005	77	1
114	114	8.20.0.0.0.021.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.021.0__patch.sql	-1039918733	ufos	2015-05-25 11:47:50.184146	9	1
115	115	8.20.0.0.0.022.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.022.0__patch.sql	1728440999	ufos	2015-05-25 11:47:50.229566	9	1
116	116	8.20.0.0.0.023.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.023.0__patch.sql	-97914058	ufos	2015-05-25 11:47:50.355819	79	1
117	117	8.20.0.0.0.024.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.024.0__patch.sql	26422134	ufos	2015-05-25 11:47:50.400188	9	1
118	118	8.20.0.0.0.025.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.025.0__patch.sql	-1609671247	ufos	2015-05-25 11:47:50.450461	17	1
119	119	8.20.0.0.0.026.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.026.0__patch.sql	-2144578153	ufos	2015-05-25 11:47:50.57615	93	1
120	120	8.20.0.0.0.027.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.027.0__patch.sql	-772066520	ufos	2015-05-25 11:47:50.618454	7	1
121	121	8.20.0.0.0.028.0	patch	SQL	/8.20.0/ufos.8.20.0.0.0.028.0__patch.sql	-116645288	ufos	2015-05-25 11:47:50.92665	268	1
122	122	8.21.0.0.0.001.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.001.0__patch.sql	695599357	ufos	2015-05-25 11:47:50.982402	8	1
123	123	8.21.0.0.0.002.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.002.0__patch.sql	-1876586635	ufos	2015-05-25 11:47:51.06688	33	1
124	124	8.21.0.0.0.003.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.003.0__patch.sql	-1039918733	ufos	2015-05-25 11:47:51.138751	21	1
125	125	8.21.0.0.0.004.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.004.0__patch.sql	-1061447239	ufos	2015-05-25 11:47:51.207044	9	1
126	126	8.21.0.0.0.005.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.005.0__patch.sql	-1394285342	ufos	2015-05-25 11:47:51.395742	143	1
127	127	8.21.0.0.0.006.0	patch	SQL	/8.21.0/ufos.8.21.0.0.0.006.0__patch.sql	-1609671247	ufos	2015-05-25 11:47:51.437374	8	1
\.

--
-- Data for Name: t_complex; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY t_complex (id, local_id, global_id, name, description, parent_complex_id, near_complex_id, active_complex_address_id, last_update_date, is_home, fingerprint, complex_type, is_secret, is_archive, username, is_offline) FROM stdin;
3001480	OEBS	OEBS	OEBS	OEBS	\N	1	3001481	2010-04-15 08:42:45	N	\N	OEBS	N	N	\N	N
1	localcomplex	localcomplex	localcomplex	localcomplex	\N	\N	\N	2015-05-26 14:54:23.444	Y	\N	SUFD	N	N	system_user	N
\.


--
-- Data for Name: t_complex_address; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY t_complex_address (id, digest, description, complex_id, max_shipment_size, crypt_required, protect_level, crypto_key_template, compress_content, username, last_update_date, groups) FROM stdin;
3001481	OEBS/${toComplex}/${subGroup}	OEBS complex outbound address	3001480	1000000000	N	MINIMAL	\N	Y	sysdba	2015-05-25 11:25:23	\N
\.



--
-- Data for Name: t_shipment_status; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY t_shipment_status (id, system_name, name) FROM stdin;
0	CREATED	Создан
1	SEND_READY	Готов к отправке
2	SENDING	Отправляется
3	SENDED	Отправлен
4	RECEIVING	Принимается
5	RECEIVED	Принят
6	UNPACKING	Распаковывается
7	UNPACKED	Распакован
8	ARCHIVE	Архив
9	PROCESSED	Успешно обработан
10	RESETTED	Сброшен
\.


COPY tb_direction (id, code_of_system, name_of_system, transport) FROM stdin;
2	OEBS	OEBS	\N
1	TEST-SYSTEM	TEST SYSTEM	\N
\.

--
-- Data for Name: usergroup; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY usergroup (usergroupid, version, name, systemname, g_exclusive, system) FROM stdin;
1	0	Администраторы	ADMINS	f	t
10	0	Смотритель формализованного журнала	formalizedJournalViewer	f	t
3002242	0	Пользователи, для которых выгрузка статистики СПТО запрещена	BanUploadingReportSPTO	f	t
3003032	0	Автоматический импорт/экспорт	AutoImportExportGroup	f	t
3003040	0	Локальные администраторы	LocalAdministrators	f	f
3003047	0	ФССП	FSSP	f	f
3003050	0	Сводная статистика	ReportStatisticSVOD	f	f
11	0	Генерация запроса на получение сертификата	CERT	f	f
\.


--
-- Data for Name: usergroupmembers; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY usergroupmembers (usergroupid, userinfoid) FROM stdin;
1	1
1	2
1	3
1	356
1	359
10	10
11	12
\.


--
-- Data for Name: usergroupstoposition; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY usergroupstoposition (usergroupid, docid) FROM stdin;
\.


--
-- Data for Name: userinfo; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY userinfo (userinfoid, version, systemname, name, locale, locked, userprofileid, passwordhash, salt, userrequisitesid, mustchangepassword, officeid, certauthorization, email, externalsystemid, title, department) FROM stdin;
356	0	123	Петров Олег Анатольевич	\N	f	3011211	\N	\N	357	f	1	f	\N	\N	\N	\N
359	0	2341244	Пупкин Иван Васильевич	\N	f	3011211	\N	\N	360	f	1	f	\N	\N	\N	\N
2	1	ic	Савельев Олег Леонидович	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
3	0	icural	Кондратьев Дмитрий Владимирович	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
4	0	transport_user	Пользователь Транспорта	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
5	0	autoproc_user	Пользователь Автопроцедур	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
7	0	docflow_user	Пользователь Документооборота	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
10	0	journalist	Смотритель формализованного журнала	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
3001482	0	jms_backoffice_user	Пользователь системы обработки jms-запросов от backoffice	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
11	0	web_service_user	Пользователь Веб сервисов	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
12	0	cert	Пользователь для получения сертификата	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
8	0	system_user	Системный пользователь	\N	f	3011211	\N	\N	\N	f	1	f	\N	\N	\N	\N
1	0	bear	Иванов Петр Дмитриевич	\N	f	3011211	\\x33396366313765313032306466386230636639616333666637666362383536313638613062373865373632626534613738346665646365656334613537626461	\\xcfbc0c90b2ffc66248c92824a411b54ed8ed9b9f673327c369b54a69b086f10518774d70725cf1f1cbab987d85533ec7ec2eccda3b6d7e21b0bc0757d76b8c9e	\N	f	1	f	\N	\N	\N	\N
\.


--
-- Data for Name: securityprofile; Type: TABLE DATA; Schema: arm_offline; Owner: arm_offline
--

COPY securityprofile (securityprofileid, version, name, maxauthattempts, allowchangepassword, minpasswordlength, passwordrequired, requestpasswordchange) FROM stdin;
3011210	2	Профиль безопасности для АРМ Офлайн	3	t	5	f	t
\.

--
-- Data for Name: userprofile; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY userprofile (userprofileid, version, name, locale, securityprofileid) FROM stdin;
3011211	1	Профиль пользователя для АРМ Офлайн	ru	3011210
\.


--
-- Data for Name: userrequisites; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY userrequisites (userrequisitesid, version, fio, inn, notes, iddocdata, iddoctype, physicaladdressid, registrationaddressid) FROM stdin;
357	0	\N	\N	\N	\N	\N	\N	\N
360	0	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: userstatistics; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY userstatistics (userstatisticsid, userinfoid, lastlogindate) FROM stdin;
3019226	1	2015-05-26
\.


--
-- Data for Name: usertoorg; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY usertoorg (userinfoid, orgid, list_index) FROM stdin;
5	1	0
4	1	0
8	1	0
7	1	0
3001482	1	0
11	1	0
1	1	0
2	1	0
3	1	0
356	1	0
359	1	0
12	1	0
\.


--
-- Data for Name: usertoorg_audit_log; Type: TABLE DATA; Schema: ufos; Owner: ufos
--

COPY usertoorg_audit_log (id, userinfoid, orgid, authoruserinfoid, audit_date) FROM stdin;
\.


ALTER TABLE ONLY schema_version
    ADD CONSTRAINT "SCHEMA_VERSION_pk" PRIMARY KEY (version);



--
-- Name: complex_address_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY t_complex_address
    ADD CONSTRAINT complex_address_pk PRIMARY KEY (id);


--
-- Name: complex_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY t_complex
    ADD CONSTRAINT complex_pk PRIMARY KEY (id);


--
-- Name: counter_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY counter
    ADD CONSTRAINT counter_pk PRIMARY KEY (id);


--
--
-- Name: doc_operations_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doc_operations
    ADD CONSTRAINT doc_operations_pk PRIMARY KEY (operation_id);


--
-- Name: docservice_operations_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docservice_operations
    ADD CONSTRAINT docservice_operations_pk PRIMARY KEY (operation_id, docserviceid);


--
-- Name: drill_down_log_doc_id_unique; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY drill_down_log
    ADD CONSTRAINT drill_down_log_doc_id_unique UNIQUE (doc_id);


--
-- Name: drill_down_log_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY drill_down_log
    ADD CONSTRAINT drill_down_log_pk PRIMARY KEY (id);


--
-- Name: dth_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doc_transport_history
    ADD CONSTRAINT dth_pk PRIMARY KEY (id);


--
-- Name: fk_docstatelog; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docstatelog
    ADD CONSTRAINT fk_docstatelog PRIMARY KEY (eventid);


--
-- Name: fk_historydoclog; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY historydoclog
    ADD CONSTRAINT fk_historydoclog PRIMARY KEY (eventid);



ALTER TABLE ONLY t_complex
    ADD CONSTRAINT global_id_uniq UNIQUE (global_id);


--
-- Name: global_notification_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY global_notification
    ADD CONSTRAINT global_notification_pk PRIMARY KEY (id);


--
-- Name: hilo_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

--
-- Name: linktype_code_unique; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY linktype
    ADD CONSTRAINT linktype_code_unique UNIQUE (systemname);


--
-- Name: operations_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT operations_pk PRIMARY KEY (operation_id);


--
-- Name: operations_uq_n; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT operations_uq_n UNIQUE (name);


--
-- Name: operations_uq_sn; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY operations
    ADD CONSTRAINT operations_uq_sn UNIQUE (system_name);



--
-- Name: pk_admincontext; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY admincontext
    ADD CONSTRAINT pk_admincontext PRIMARY KEY (contextid);


--
-- Name: pk_adminservice; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY adminservice
    ADD CONSTRAINT pk_adminservice PRIMARY KEY (adminserviceid);


--
-- Name: pk_adminsubmenu; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY adminsubmenu
    ADD CONSTRAINT pk_adminsubmenu PRIMARY KEY (adminsubmenuid);


ALTER TABLE ONLY alerts
    ADD CONSTRAINT pk_alerts PRIMARY KEY (alertid);


--
-- Name: pk_ap_argument_value; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_argument_value
    ADD CONSTRAINT pk_ap_argument_value PRIMARY KEY (id);


--
-- Name: pk_ap_condition; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_condition
    ADD CONSTRAINT pk_ap_condition PRIMARY KEY (id);


--
-- Name: pk_ap_condition_calendar; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_condition_calendar
    ADD CONSTRAINT pk_ap_condition_calendar PRIMARY KEY (id);


--
-- Name: pk_ap_condition_event; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_condition_event
    ADD CONSTRAINT pk_ap_condition_event PRIMARY KEY (id);


--
-- Name: pk_ap_condition_file; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_condition_file
    ADD CONSTRAINT pk_ap_condition_file PRIMARY KEY (id);


--
-- Name: pk_ap_condition_posttask; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_condition_posttask
    ADD CONSTRAINT pk_ap_condition_posttask PRIMARY KEY (id);


--
-- Name: pk_ap_task; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_task
    ADD CONSTRAINT pk_ap_task PRIMARY KEY (id);


--
-- Name: pk_ap_task_process_journal; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_task_process_journal
    ADD CONSTRAINT pk_ap_task_process_journal PRIMARY KEY (id);


--
-- Name: pk_attach; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY attach
    ADD CONSTRAINT pk_attach PRIMARY KEY (attachid);


ALTER TABLE ONLY cg_sign_info
    ADD CONSTRAINT pk_certjsubstit PRIMARY KEY (id);


--
-- Name: pk_cg_algorithm; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_algorithm
    ADD CONSTRAINT pk_cg_algorithm PRIMARY KEY (id);


--
-- Name: pk_cg_attach_sign_info; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_attach_sign_info
    ADD CONSTRAINT pk_cg_attach_sign_info PRIMARY KEY (id);


--
-- Name: pk_cg_basecrl_update_info; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_basecrl_update_info
    ADD CONSTRAINT pk_cg_basecrl_update_info PRIMARY KEY (authority_key_id);


--
-- Name: pk_cg_cert_info; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_cert_info
    ADD CONSTRAINT pk_cg_cert_info PRIMARY KEY (id);


--
-- Name: pk_cg_cert_j_doctype; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_cert_j_doctype
    ADD CONSTRAINT pk_cg_cert_j_doctype PRIMARY KEY (cert_info_id, doc_type_id);


--
-- Name: pk_cg_csp_info; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_csp_info
    ADD CONSTRAINT pk_cg_csp_info PRIMARY KEY (id);


--
-- Name: pk_cg_da_assignment_org; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_assignment_org
    ADD CONSTRAINT pk_cg_da_assignment_org PRIMARY KEY (id);


--
-- Name: pk_cg_da_doc; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_doc
    ADD CONSTRAINT pk_cg_da_doc PRIMARY KEY (id);


--
-- Name: pk_cg_da_doc_level_rule; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_doc_level_rule
    ADD CONSTRAINT pk_cg_da_doc_level_rule PRIMARY KEY (id);


--
-- Name: pk_cg_da_doc_org_rule; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_doc_org_rule
    ADD CONSTRAINT pk_cg_da_doc_org_rule PRIMARY KEY (id);


--
-- Name: pk_cg_da_doc_stage; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_doc_stage
    ADD CONSTRAINT pk_cg_da_doc_stage PRIMARY KEY (id);


--
-- Name: pk_cg_da_doc_stage_approver; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_doc_stage_approver
    ADD CONSTRAINT pk_cg_da_doc_stage_approver PRIMARY KEY (id);


--
-- Name: pk_cg_da_org_hierarchy; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_org_hierarchy
    ADD CONSTRAINT pk_cg_da_org_hierarchy PRIMARY KEY (id);


--
-- Name: pk_cg_da_param; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_param
    ADD CONSTRAINT pk_cg_da_param PRIMARY KEY (id);


--
-- Name: pk_cg_da_proc_result; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_proc_result
    ADD CONSTRAINT pk_cg_da_proc_result PRIMARY KEY (id);


--
-- Name: pk_cg_da_proc_stage; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_proc_stage
    ADD CONSTRAINT pk_cg_da_proc_stage PRIMARY KEY (id);


--
-- Name: pk_cg_da_process; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_process
    ADD CONSTRAINT pk_cg_da_process PRIMARY KEY (id);


--
-- Name: pk_cg_da_role; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_role
    ADD CONSTRAINT pk_cg_da_role PRIMARY KEY (id);


--
-- Name: pk_cg_da_role_item; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_role_item
    ADD CONSTRAINT pk_cg_da_role_item PRIMARY KEY (id);


--
-- Name: pk_cg_da_subst_user; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_subst_user
    ADD CONSTRAINT pk_cg_da_subst_user PRIMARY KEY (id);


--
-- Name: pk_cg_da_user_absence; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_user_absence
    ADD CONSTRAINT pk_cg_da_user_absence PRIMARY KEY (id);


--
-- Name: pk_cg_da_user_assignment; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_user_assignment
    ADD CONSTRAINT pk_cg_da_user_assignment PRIMARY KEY (id);


--
-- Name: pk_cg_da_user_assignment_role; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_user_assignment_role
    ADD CONSTRAINT pk_cg_da_user_assignment_role PRIMARY KEY (id);


--
-- Name: pk_cg_da_user_subst; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_da_user_subst
    ADD CONSTRAINT pk_cg_da_user_subst PRIMARY KEY (id);


--
-- Name: pk_cg_doc_sign_info; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_doc_sign_info
    ADD CONSTRAINT pk_cg_doc_sign_info PRIMARY KEY (id);


--
-- Name: pk_cg_exserv_connection; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_exserv_connection
    ADD CONSTRAINT pk_cg_exserv_connection PRIMARY KEY (id);


--
-- Name: pk_cg_protection_desc; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_protection_desc
    ADD CONSTRAINT pk_cg_protection_desc PRIMARY KEY (id);


--
-- Name: pk_cg_sign_scheme; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_sign_scheme
    ADD CONSTRAINT pk_cg_sign_scheme PRIMARY KEY (id);


--
-- Name: pk_cg_sscheme_changing_track; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_sscheme_changing_track
    ADD CONSTRAINT pk_cg_sscheme_changing_track PRIMARY KEY (id);


--
-- Name: pk_cg_user_profile; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_user_profile
    ADD CONSTRAINT pk_cg_user_profile PRIMARY KEY (id);



ALTER TABLE ONLY complex_role
    ADD CONSTRAINT pk_complex_role PRIMARY KEY (id);



ALTER TABLE ONLY corrupteddoc
    ADD CONSTRAINT pk_corrupted_doc PRIMARY KEY (docid);


--
-- Name: pk_counterconfig; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY counterconfiguration
    ADD CONSTRAINT pk_counterconfig PRIMARY KEY (id);


--
-- Name: pk_cryptotype; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cryptotype
    ADD CONSTRAINT pk_cryptotype PRIMARY KEY (cryptotypeid);



ALTER TABLE ONLY dict
    ADD CONSTRAINT pk_dict PRIMARY KEY (dictid);


--
-- Name: pk_dict_log; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY dict_log
    ADD CONSTRAINT pk_dict_log PRIMARY KEY (id);


--
-- Name: pk_dict_type; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY dict_type
    ADD CONSTRAINT pk_dict_type PRIMARY KEY (id);



ALTER TABLE ONLY dictchangelog
    ADD CONSTRAINT pk_dictchangelog PRIMARY KEY (id);



ALTER TABLE ONLY doc
    ADD CONSTRAINT pk_doc PRIMARY KEY (docid);


--
-- Name: pk_doc_filter_condition; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doc_filter_condition
    ADD CONSTRAINT pk_doc_filter_condition PRIMARY KEY (id);


--
-- Name: pk_doc_filter_condition_group; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doc_filter_condition_group
    ADD CONSTRAINT pk_doc_filter_condition_group PRIMARY KEY (id);


--
-- Name: pk_doc_filters; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doc_filters
    ADD CONSTRAINT pk_doc_filters PRIMARY KEY (id);


--
-- Name: pk_docchangelog; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docchangelog
    ADD CONSTRAINT pk_docchangelog PRIMARY KEY (id);


--
-- Name: pk_doceventid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY log_docevent
    ADD CONSTRAINT pk_doceventid PRIMARY KEY (id);


--
-- Name: pk_docfieldchangelog; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docfieldchangelog
    ADD CONSTRAINT pk_docfieldchangelog PRIMARY KEY (id);


--
-- Name: pk_docfilling; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docfilling
    ADD CONSTRAINT pk_docfilling PRIMARY KEY (fillingid);


--
-- Name: pk_docfillingdependency; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docfillingdependency
    ADD CONSTRAINT pk_docfillingdependency PRIMARY KEY (dependonid, dependfromid);


--
-- Name: pk_doclifecyclevisedactions; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doclifecyclevisedactions
    ADD CONSTRAINT pk_doclifecyclevisedactions PRIMARY KEY (doclifecycleid, visedactionid);


--
-- Name: pk_doclink; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doclink
    ADD CONSTRAINT pk_doclink PRIMARY KEY (id);


--
-- Name: pk_docservice; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docservice
    ADD CONSTRAINT pk_docservice PRIMARY KEY (docserviceid);


--
-- Name: pk_docstate; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docstate
    ADD CONSTRAINT pk_docstate PRIMARY KEY (docstateid);


ALTER TABLE ONLY doctype
    ADD CONSTRAINT pk_doctype PRIMARY KEY (doctypeid);


--
-- Name: pk_encloseddoc; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY encloseddoc
    ADD CONSTRAINT pk_encloseddoc PRIMARY KEY (docid);


--
-- Name: pk_eventid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY log_fiscaljournal
    ADD CONSTRAINT pk_eventid PRIMARY KEY (eventid);


--
-- Name: pk_exclusiveday; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY exclusiveday
    ADD CONSTRAINT pk_exclusiveday PRIMARY KEY (exclusivedayid);


--
-- Name: pk_groupcounterconfig; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY groupcounterconfiguration
    ADD CONSTRAINT pk_groupcounterconfig PRIMARY KEY (id);


--
-- Name: pk_groupstoposition; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY usergroupstoposition
    ADD CONSTRAINT pk_groupstoposition PRIMARY KEY (usergroupid, docid);


--
-- Name: pk_history; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY history
    ADD CONSTRAINT pk_history PRIMARY KEY (id);


--
-- Name: pk_historyattributes; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY historyattributes
    ADD CONSTRAINT pk_historyattributes PRIMARY KEY (id);


--
-- Name: pk_historyextension; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY historyextension
    ADD CONSTRAINT pk_historyextension PRIMARY KEY (id);

--
-- Name: pk_jms_messages; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY jms_messages
    ADD CONSTRAINT pk_jms_messages PRIMARY KEY (messageid, destination);


--
-- Name: pk_jms_subscriptions; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY jms_subscriptions
    ADD CONSTRAINT pk_jms_subscriptions PRIMARY KEY (clientid, subname);


--
-- Name: pk_linktype; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY linktype
    ADD CONSTRAINT pk_linktype PRIMARY KEY (id);


--
-- Name: pk_list_attachments; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY list_attachments
    ADD CONSTRAINT pk_list_attachments PRIMARY KEY (fieldsetid);


ALTER TABLE ONLY localcomplex
    ADD CONSTRAINT pk_localcomplex PRIMARY KEY (localcomplexid);


--
-- Name: pk_log_clear_queue; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY log_clear_queue
    ADD CONSTRAINT pk_log_clear_queue PRIMARY KEY (id);


--
-- Name: pk_log_disabledfiscalevent; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY log_disabledfiscalevent
    ADD CONSTRAINT pk_log_disabledfiscalevent PRIMARY KEY (doctypesystemname, eventsystemname);


ALTER TABLE ONLY org
    ADD CONSTRAINT pk_org PRIMARY KEY (orgid);


--
-- Name: pk_orgcontacts; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY orgcontacts
    ADD CONSTRAINT pk_orgcontacts PRIMARY KEY (orgcontactsid);


--
-- Name: pk_orgdata; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY orgdata
    ADD CONSTRAINT pk_orgdata PRIMARY KEY (orgdataid);


--
-- Name: pk_orgdocserviceexclude; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY orgdocserviceexclude
    ADD CONSTRAINT pk_orgdocserviceexclude PRIMARY KEY (orgid, docserviceid);


--
-- Name: pk_orgdoctypeexclude; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY orgdoctypeexclude
    ADD CONSTRAINT pk_orgdoctypeexclude PRIMARY KEY (orgid, doctypeid);


--
-- Name: pk_orgtype; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY orgtype
    ADD CONSTRAINT pk_orgtype PRIMARY KEY (orgtypeid);


ALTER TABLE ONLY pref_node
    ADD CONSTRAINT pk_pref_node PRIMARY KEY (id);


--
-- Name: pk_pref_property; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY pref_property
    ADD CONSTRAINT pk_pref_property PRIMARY KEY (id);



ALTER TABLE ONLY queue_document
    ADD CONSTRAINT pk_queue_document PRIMARY KEY (guid);


--
-- Name: pk_queue_in_pack2docq; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_in_pack2docq
    ADD CONSTRAINT pk_queue_in_pack2docq PRIMARY KEY (in_packet_id, docqueue_id);


--
-- Name: pk_queue_multi_part_packet_in; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_multi_part_packet_in
    ADD CONSTRAINT pk_queue_multi_part_packet_in PRIMARY KEY (id);


--
-- Name: pk_queue_out_pack2docq; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_out_pack2docq
    ADD CONSTRAINT pk_queue_out_pack2docq PRIMARY KEY (out_packet_id, docqueue_id);


--
-- Name: pk_queue_packet_in; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_packet_in
    ADD CONSTRAINT pk_queue_packet_in PRIMARY KEY (id);


--
-- Name: pk_queue_packet_out; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_packet_out
    ADD CONSTRAINT pk_queue_packet_out PRIMARY KEY (id);



--
-- Name: pk_routecontext; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY routecontext
    ADD CONSTRAINT pk_routecontext PRIMARY KEY (routecontextid);


--
-- Name: pk_rpl_sent_object; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY rpl_sent_object
    ADD CONSTRAINT pk_rpl_sent_object PRIMARY KEY (id);


--
-- Name: pk_securityprofile; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY securityprofile
    ADD CONSTRAINT pk_securityprofile PRIMARY KEY (securityprofileid);



ALTER TABLE ONLY queue_packet_in_seq_guids
    ADD CONSTRAINT pk_seqguid PRIMARY KEY (seqguid);



--
-- Name: pk_sys_const_group; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY sys_const_group
    ADD CONSTRAINT pk_sys_const_group PRIMARY KEY (groupid);


--
-- Name: pk_system_const; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY system_const
    ADD CONSTRAINT pk_system_const PRIMARY KEY (id);


--
-- Name: pk_system_const_type; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY system_const_type
    ADD CONSTRAINT pk_system_const_type PRIMARY KEY (typeid);


--
-- Name: pk_system_formalized_journal; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY system_formalized_journal
    ADD CONSTRAINT pk_system_formalized_journal PRIMARY KEY (event_time, subsystem_code, operation_code, operation_res, object_type, key_param);


--
-- Name: pk_t_security_fields; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY t_security_fields
    ADD CONSTRAINT pk_t_security_fields PRIMARY KEY (id);



ALTER TABLE ONLY task
    ADD CONSTRAINT pk_task PRIMARY KEY (taskid);


--
-- Name: pk_taskconditions; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY taskconditions
    ADD CONSTRAINT pk_taskconditions PRIMARY KEY (scheduleid);


--
-- Name: pk_taskgroup; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY taskgroup
    ADD CONSTRAINT pk_taskgroup PRIMARY KEY (taskid);


--
-- Name: pk_taskrestrictions; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY taskrestrictions
    ADD CONSTRAINT pk_taskrestrictions PRIMARY KEY (scheduleid);


--
-- Name: pk_tb_direction; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY tb_direction
    ADD CONSTRAINT pk_tb_direction PRIMARY KEY (id);


--
-- Name: pk_tb_event; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY tb_event
    ADD CONSTRAINT pk_tb_event PRIMARY KEY (event_id);


--
-- Name: pk_tb_message; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY tb_message
    ADD CONSTRAINT pk_tb_message PRIMARY KEY (id);


--
-- Name: pk_tb_message_big_attributes; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY tb_message_big_attributes
    ADD CONSTRAINT pk_tb_message_big_attributes PRIMARY KEY (id);


--
-- Name: pk_td_id; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY typedoc
    ADD CONSTRAINT pk_td_id PRIMARY KEY (id);




ALTER TABLE ONLY jms_transactions
    ADD CONSTRAINT pk_txid PRIMARY KEY (txid);


--
-- Name: pk_user_notifications; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY user_notifications
    ADD CONSTRAINT pk_user_notifications PRIMARY KEY (guid);


--
-- Name: pk_user_to_alert; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY user_to_alert
    ADD CONSTRAINT pk_user_to_alert PRIMARY KEY (userinfoid, alertid);


--
-- Name: pk_usercounterconfig; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY usercounterconfiguration
    ADD CONSTRAINT pk_usercounterconfig PRIMARY KEY (id);


--
-- Name: pk_usergroup; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY usergroup
    ADD CONSTRAINT pk_usergroup PRIMARY KEY (usergroupid);


--
-- Name: pk_usergroupmembers; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY usergroupmembers
    ADD CONSTRAINT pk_usergroupmembers PRIMARY KEY (usergroupid, userinfoid);


--
-- Name: pk_userid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY jms_users
    ADD CONSTRAINT pk_userid PRIMARY KEY (userid);


--
-- Name: pk_userid_roleid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY jms_roles
    ADD CONSTRAINT pk_userid_roleid PRIMARY KEY (userid, roleid);


--
-- Name: pk_userinfo; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userinfo
    ADD CONSTRAINT pk_userinfo PRIMARY KEY (userinfoid);


--
-- Name: pk_userprofile; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userprofile
    ADD CONSTRAINT pk_userprofile PRIMARY KEY (userprofileid);


--
-- Name: pk_userrequisites; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userrequisites
    ADD CONSTRAINT pk_userrequisites PRIMARY KEY (userrequisitesid);


--
-- Name: pk_userstatistics; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userstatistics
    ADD CONSTRAINT pk_userstatistics PRIMARY KEY (userstatisticsid);


--
-- Name: pk_usersubstit; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_user_substitution
    ADD CONSTRAINT pk_usersubstit PRIMARY KEY (id);


--
-- Name: pk_usertoorg_audit_log; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY usertoorg_audit_log
    ADD CONSTRAINT pk_usertoorg_audit_log PRIMARY KEY (id);



ALTER TABLE ONLY queue_document_in_ids
    ADD CONSTRAINT queue_document_in_ids_pk PRIMARY KEY (id);


--
-- Name: queue_document_out_ids_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_document_out_ids
    ADD CONSTRAINT queue_document_out_ids_pk PRIMARY KEY (id);


--
-- Name: queue_packet_in_ids_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_packet_in_ids
    ADD CONSTRAINT queue_packet_in_ids_pk PRIMARY KEY (id);


--
-- Name: queue_packet_out_ids_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY queue_packet_out_ids
    ADD CONSTRAINT queue_packet_out_ids_pk PRIMARY KEY (id);


--
-- Name: rpl_object_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY rpl_object
    ADD CONSTRAINT rpl_object_pk PRIMARY KEY (id);


--
-- Name: rpl_receiver_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY rpl_receiver
    ADD CONSTRAINT rpl_receiver_pk PRIMARY KEY (id);


--
-- Name: rpl_subscription_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY rpl_subscription
    ADD CONSTRAINT rpl_subscription_pk PRIMARY KEY (id);


--
-- Name: securityfield_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY securityfield
    ADD CONSTRAINT securityfield_pk PRIMARY KEY (id);


--
-- Name: shipment_status_pk; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY t_shipment_status
    ADD CONSTRAINT shipment_status_pk PRIMARY KEY (id);


--
-- Name: sys_c00435885; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT sys_c00435885 UNIQUE (systemname);


--
-- Name: sys_c00436351; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY task_history
    ADD CONSTRAINT sys_c00436351 PRIMARY KEY (id);



ALTER TABLE ONLY admincontext
    ADD CONSTRAINT u_admincontext_name UNIQUE (name);


--
-- Name: u_ap_condition$name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_condition
    ADD CONSTRAINT "u_ap_condition$name" UNIQUE (name);


--
-- Name: u_ap_task$name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY ap_task
    ADD CONSTRAINT "u_ap_task$name" UNIQUE (name);



--
-- Name: u_auditgroup_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY auditgroup
    ADD CONSTRAINT u_auditgroup_name UNIQUE (grouptype);


--
-- Name: u_commontask_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY commontask
    ADD CONSTRAINT u_commontask_name UNIQUE (name);


--
-- Name: u_complex_role_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY complex_role
    ADD CONSTRAINT u_complex_role_systemname UNIQUE (systemname);


--
-- Name: u_cryptotype_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cryptotype
    ADD CONSTRAINT u_cryptotype_name UNIQUE (name);


--
-- Name: u_dict_guid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY dict
    ADD CONSTRAINT u_dict_guid UNIQUE (globaldocid);


--
-- Name: u_dicttffschemaversion_id; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY dicttffschemaversion
    ADD CONSTRAINT u_dicttffschemaversion_id UNIQUE (id);


--
-- Name: u_doc_guid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doc
    ADD CONSTRAINT u_doc_guid UNIQUE (globaldocid);



ALTER TABLE ONLY docfilling
    ADD CONSTRAINT u_docfilling_typeorgname UNIQUE (doctypeid, orgid, fieldname);


--
-- Name: u_docservice_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docservice
    ADD CONSTRAINT u_docservice_systemname UNIQUE (systemname);


--
-- Name: u_docstate_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY docstate
    ADD CONSTRAINT u_docstate_systemname UNIQUE (systemname);


--
-- Name: u_doctype_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY doctype
    ADD CONSTRAINT u_doctype_systemname UNIQUE (systemname);


--
-- Name: u_encloseddoc_enclosednum; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY encloseddoc
    ADD CONSTRAINT u_encloseddoc_enclosednum UNIQUE (parentdocid, enclosenum);


--
-- Name: u_exclusiveday_calendardate; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY exclusiveday
    ADD CONSTRAINT u_exclusiveday_calendardate UNIQUE (calendardate);



ALTER TABLE ONLY localcomplex
    ADD CONSTRAINT u_localcomplex_systemname UNIQUE (systemname);


--
-- Name: u_log_docevent_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY log_docevent
    ADD CONSTRAINT u_log_docevent_systemname UNIQUE (systemname);



ALTER TABLE ONLY org
    ADD CONSTRAINT u_org_systemname UNIQUE (systemname);


--
-- Name: u_orgtype_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY orgtype
    ADD CONSTRAINT u_orgtype_name UNIQUE (name);




--
-- Name: u_securityprofile_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY securityprofile
    ADD CONSTRAINT u_securityprofile_name UNIQUE (name);


--
-- Name: u_standconnection_unique_field; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY standconnection
    ADD CONSTRAINT u_standconnection_unique_field UNIQUE (unique_field);


--
-- Name: u_system_const_type_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY system_const_type
    ADD CONSTRAINT u_system_const_type_systemname UNIQUE (systemname);


--
-- Name: u_tab_testtype_clients_ent; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY tbl_testtype_clients
    ADD CONSTRAINT u_tab_testtype_clients_ent UNIQUE (entityid);


--
-- Name: u_taskconditions_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY taskconditions
    ADD CONSTRAINT u_taskconditions_name UNIQUE (taskid, name);


--
-- Name: u_taskrestrictions_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY taskrestrictions
    ADD CONSTRAINT u_taskrestrictions_name UNIQUE (taskid, name);


--
-- Name: u_title_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY title
    ADD CONSTRAINT u_title_name UNIQUE (name);


--
-- Name: u_userinfo_systemname; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userinfo
    ADD CONSTRAINT u_userinfo_systemname UNIQUE (systemname);


--
-- Name: u_userprofile_name; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userprofile
    ADD CONSTRAINT u_userprofile_name UNIQUE (name);


--
-- Name: u_userstatistics_userinfo; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY userstatistics
    ADD CONSTRAINT u_userstatistics_userinfo UNIQUE (userinfoid);



ALTER TABLE ONLY cg_cert_info
    ADD CONSTRAINT uk_cg_cert_info_fp UNIQUE (fingerprint);


--
-- Name: uk_cg_cert_info_subjkeyid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_cert_info
    ADD CONSTRAINT uk_cg_cert_info_subjkeyid UNIQUE (subject_key_identifier);


--
-- Name: uk_diclog_dicname_guid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY dict_log
    ADD CONSTRAINT uk_diclog_dicname_guid UNIQUE (dictname, guid);


--
-- Name: uk_key_cg_exservconn_n; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_exserv_connection
    ADD CONSTRAINT uk_key_cg_exservconn_n UNIQUE (name);


--
-- Name: uk_routecontext_docid_orgid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY routecontext
    ADD CONSTRAINT uk_routecontext_docid_orgid UNIQUE (docid, orgid);


--
-- Name: uk_sign_scheme_guid; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY cg_sign_scheme
    ADD CONSTRAINT uk_sign_scheme_guid UNIQUE (guid);


--
-- Name: unq_usertoorg_userid_index; Type: CONSTRAINT; Schema: ufos; Owner: ufos; Tablespace: 
--

ALTER TABLE ONLY usertoorg
    ADD CONSTRAINT unq_usertoorg_userid_index UNIQUE (userinfoid, list_index);



--
-- Name: SCHEMA_VERSION_ir_idx; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX "SCHEMA_VERSION_ir_idx" ON schema_version USING btree (installed_rank);


--
-- Name: SCHEMA_VERSION_s_idx; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX "SCHEMA_VERSION_s_idx" ON schema_version USING btree (success);


--
-- Name: SCHEMA_VERSION_vr_idx; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX "SCHEMA_VERSION_vr_idx" ON schema_version USING btree (version_rank);


--
-- Name: attach_dict_attachid; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX attach_dict_attachid ON attach_dict USING btree (attachid);


--
-- Name: attach_dictid; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX attach_dictid ON attach_dict USING btree (dictid);


--
-- Name: attach_doc_attachid; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX attach_doc_attachid ON attach_doc USING btree (attachid);


--
-- Name: attach_docid; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX attach_docid ON attach_doc USING btree (docid);


--
-- Name: counter_unique_index; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE UNIQUE INDEX counter_unique_index ON counter USING btree (counterfieldname, doctypeid, orgid, year, month, quarter, week, day, fld1_value, fld2_value, fld3_value, fld4_value, fld5_value);



--
-- Name: idx_changelog_dict; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_changelog_dict ON dictchangelog USING btree (dictid);


--
-- Name: idx_changelog_routecontext; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_changelog_routecontext ON docchangelog USING btree (routecontextid);


--
-- Name: idx_dicttffschemaversion; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_dicttffschemaversion ON dicttffschemaversion USING btree (marker, fd, td, isarchive);


--
-- Name: idx_fieldchangelog_changelog; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fieldchangelog_changelog ON docfieldchangelog USING btree (docchangelogid);


--
-- Name: idx_fieldchlog_dictchangelog; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fieldchlog_dictchangelog ON dictfieldchangelog USING btree (dictchangelogid);


--
-- Name: idx_fk_00000007; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000007 ON org USING btree (orgdataid);


--
-- Name: idx_fk_00000008; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000008 ON org USING btree (remotecomplexid);


--
-- Name: idx_fk_00000013; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000013 ON task USING btree (parentid);


--
-- Name: idx_fk_00000019; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000019 ON doctype USING btree (docserviceid);


--
-- Name: idx_fk_00000021; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000021 ON orgdata USING btree (orgtypeid);


--
-- Name: idx_fk_00000022; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000022 ON orgdata USING btree (orgcontactsid);


--
-- Name: idx_fk_00000023; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000023 ON orgdata USING btree (legaladdressid);


--
-- Name: idx_fk_00000024; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000024 ON orgdata USING btree (internationaladdressid);


--
-- Name: idx_fk_00000025; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000025 ON userinfo USING btree (userprofileid);


--
-- Name: idx_fk_00000026; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000026 ON userinfo USING btree (userrequisitesid);


--
-- Name: idx_fk_00000030; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000030 ON taskgroup USING btree (parentid);


--
-- Name: idx_fk_00000031; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000031 ON t_complex USING btree (near_complex_id);


--
-- Name: idx_fk_00000032; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000032 ON t_complex USING btree (parent_complex_id);


--
-- Name: idx_fk_00000033; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000033 ON t_complex USING btree (active_complex_address_id);


--
-- Name: idx_fk_00000034; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000034 ON usertoorg USING btree (orgid);


--
-- Name: idx_fk_00000035; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000035 ON usertoorg USING btree (userinfoid);


--
-- Name: idx_fk_00000037; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000037 ON docfilling USING btree (orgid);


--
-- Name: idx_fk_00000038; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000038 ON rpl_object USING btree (dicttypeid);


--
-- Name: idx_fk_00000041; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000041 ON approvalset USING btree (actionid);


--
-- Name: idx_fk_00000042; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000042 ON approvalset USING btree (doctypeid);


--
-- Name: idx_fk_00000045; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000045 ON cg_csp_info USING btree (cipher_algorithm_id);


--
-- Name: idx_fk_00000046; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000046 ON cg_csp_info USING btree (sign_algorithm_id);


--
-- Name: idx_fk_00000047; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000047 ON cg_csp_info USING btree (hash_algorithm_id);


--
-- Name: idx_fk_00000048; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000048 ON coraccounts USING btree (accountid);


--
-- Name: idx_fk_00000049; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000049 ON docstatelog USING btree (newstateid);


--
-- Name: idx_fk_00000050; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000050 ON docstatelog USING btree (oldstateid);


--
-- Name: idx_fk_00000051; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000051 ON docstatelog USING btree (userid);


--
-- Name: idx_fk_00000052; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000052 ON userprofile USING btree (securityprofileid);


--
-- Name: idx_fk_00000053; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000053 ON admincontext USING btree (defaultorgtypeid);


--
-- Name: idx_fk_00000055; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000055 ON cg_sign_info USING btree (cipher_algorithm_id);


--
-- Name: idx_fk_00000056; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000056 ON cg_sign_info USING btree (hash_algorithm_id);


--
-- Name: idx_fk_00000057; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000057 ON cg_sign_info USING btree (csp_info_id);


--
-- Name: idx_fk_00000059; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000059 ON routecontext USING btree (ownerid);


--
-- Name: idx_fk_00000060; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000060 ON routecontext USING btree (docid);


--
-- Name: idx_fk_00000061; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000061 ON routecontext USING btree (localdocstateid);


--
-- Name: idx_fk_00000062; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000062 ON rpl_receiver USING btree (complexid);


--
-- Name: idx_fk_00000063; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000063 ON system_const USING btree (orgid);


--
-- Name: idx_fk_00000064; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000064 ON system_const USING btree (typeid);


--
-- Name: idx_fk_00000065; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000065 ON historydoclog USING btree (newstateid);


--
-- Name: idx_fk_00000066; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000066 ON historydoclog USING btree (oldstateid);


--
-- Name: idx_fk_00000067; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000067 ON historydoclog USING btree (userid);


--
-- Name: idx_fk_00000068; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000068 ON securityfield USING btree (doc_type_id);


--
-- Name: idx_fk_00000069; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000069 ON cg_sign_scheme USING btree (doc_type_id);


--
-- Name: idx_fk_00000070; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000070 ON cryptosettings USING btree (cryptotypeid);


--
-- Name: idx_fk_00000071; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000071 ON userrequisites USING btree (registrationaddressid);


--
-- Name: idx_fk_00000072; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000072 ON userrequisites USING btree (physicaladdressid);


--
-- Name: idx_fk_00000073; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000073 ON cg_user_profile USING btree (arch_algorithm_id);


--
-- Name: idx_fk_00000074; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000074 ON cg_user_profile USING btree (protect_desc_min_id);


--
-- Name: idx_fk_00000075; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000075 ON cg_user_profile USING btree (protect_desc_av_id);


--
-- Name: idx_fk_00000076; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000076 ON cg_user_profile USING btree (checksum_algorithm_id);


--
-- Name: idx_fk_00000077; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000077 ON rpl_sent_object USING btree (dicttypeid);


--
-- Name: idx_fk_00000078; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000078 ON rpl_sent_object USING btree (complexid);


--
-- Name: idx_fk_00000081; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000081 ON cg_da_subst_user USING btree (user_id);


--
-- Name: idx_fk_00000083; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000083 ON cg_doc_sign_info USING btree (sign_scheme_id);


--
-- Name: idx_fk_00000084; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000084 ON usergroupmembers USING btree (userinfoid);


--
-- Name: idx_fk_00000086; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000086 ON ap_argument_value USING btree (task_id);


--
-- Name: idx_fk_00000087; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000087 ON cg_cert_j_doctype USING btree (doc_type_id);


--
-- Name: idx_fk_00000091; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000091 ON orgdoctypeexclude USING btree (doctypeid);


--
-- Name: idx_fk_00000093; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000093 ON t_complex_address USING btree (complex_id);


--
-- Name: idx_fk_00000094; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000094 ON cg_protection_desc USING btree (hash_algorithm_id);


--
-- Name: idx_fk_00000095; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000095 ON cg_protection_desc USING btree (cipher_algorithm_id);


--
-- Name: idx_fk_00000096; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000096 ON queue_in_pack2docq USING btree (docqueue_id);


--
-- Name: idx_fk_00000097; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000097 ON ap_task_j_condition USING btree (task_id);


--
-- Name: idx_fk_00000098; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000098 ON ap_task_j_condition USING btree (condition_id);


--
-- Name: idx_fk_00000099; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000099 ON cg_attach_sign_info USING btree (attach_id);


--
-- Name: idx_fk_00000101; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000101 ON historydoclogdetail USING btree (eventid);


--
-- Name: idx_fk_00000102; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000102 ON queue_out_pack2docq USING btree (docqueue_id);


--
-- Name: idx_fk_00000103; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000103 ON cg_user_substitution USING btree (substed_userinfo_id);


--
-- Name: idx_fk_00000104; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000104 ON cg_user_substitution USING btree (substing_userinfo_id);


--
-- Name: idx_fk_00000105; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000105 ON cg_user_substitution USING btree (prev_user_substit_id);


--
-- Name: idx_fk_00000107; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000107 ON docfillingdependency USING btree (dependfromid);


--
-- Name: idx_fk_00000110; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000110 ON orgdocserviceexclude USING btree (docserviceid);


--
-- Name: idx_fk_00000112; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000112 ON ap_condition_posttask USING btree (precede_task_id);


--
-- Name: idx_fk_00000114; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000114 ON docservice_operations USING btree (docserviceid);


--
-- Name: idx_fk_00000115; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000115 ON document_queue_to_org USING btree (org_id);


--
-- Name: idx_fk_00000116; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000116 ON document_queue_to_org USING btree (document_guid);


--
-- Name: idx_fk_00000117; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000117 ON doc_transport_history USING btree (doc_id);


--
-- Name: idx_fk_00000119; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000119 ON cg_cert_j_substitution USING btree (cert_info_id);


--
-- Name: idx_fk_00000120; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000120 ON cg_cert_j_substitution USING btree (user_substitution_id);


--
-- Name: idx_fk_00000126; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000126 ON rpl_subscription_object USING btree (rpl_subscription_id);


--
-- Name: idx_fk_00000127; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000127 ON rpl_subscription_object USING btree (rpl_object_id);


--
-- Name: idx_fk_00000128; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000128 ON doclifecyclevisedactions USING btree (visedactionid);


--
-- Name: idx_fk_00000129; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000129 ON cg_sscheme_changing_track USING btree (userinfo_id);


--
-- Name: idx_fk_00000130; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000130 ON doccontent_dicttransphist USING btree (doctypeid);


--
-- Name: idx_fk_00000131; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000131 ON rpl_receiver_subscription USING btree (rpl_receiver_id);


--
-- Name: idx_fk_00000132; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000132 ON rpl_receiver_subscription USING btree (rpl_subscription_id);

--

CREATE INDEX idx_fk_00000318 ON log_fiscaljournal USING btree (doctypeid);


--
-- Name: idx_fk_00000319; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000319 ON log_fiscaljournal USING btree (eventtypeid);


--
-- Name: idx_fk_00000320; Type: INDEX; Schema: ufos; Owner: ufos; Tablespace: 
--

CREATE INDEX idx_fk_00000320 ON log_fiscaljournal USING btree (docstateid);


CREATE INDEX idx_fk_00000351 ON user_to_alert USING btree (alertid);

CREATE INDEX idx_fk_attach_abstractdoc ON attach USING btree (docid_old);
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
--
-- Name: java_guid(); Type: ACL; Schema: ufos; Owner: ufos
--

REVOKE ALL ON FUNCTION java_guid() FROM PUBLIC;
REVOKE ALL ON FUNCTION java_guid() FROM ufos;
GRANT ALL ON FUNCTION java_guid() TO ufos;
GRANT ALL ON FUNCTION java_guid() TO PUBLIC;

REVOKE ALL ON FUNCTION java_guid() FROM PUBLIC;
REVOKE ALL ON FUNCTION java_guid() FROM ufos;
GRANT ALL ON FUNCTION java_guid() TO ufos;
GRANT ALL ON FUNCTION java_guid() TO PUBLIC;


--
-- Name: pk_postaladdress; Type: CONSTRAINT; Schema: arm_offline; Owner: arm_offline; Tablespace:
--

ALTER TABLE ONLY postaladdress
    ADD CONSTRAINT pk_postaladdress PRIMARY KEY (postaladdressid);


    --
-- Name: fk_orgdata_internaddress; Type: FK CONSTRAINT; Schema: arm_offline; Owner: arm_offline
--

ALTER TABLE ONLY orgdata
    ADD CONSTRAINT fk_orgdata_internaddress FOREIGN KEY (internationaladdressid) REFERENCES postaladdress(postaladdressid) MATCH FULL;


--
-- Name: fk_orgdata_legaladdress; Type: FK CONSTRAINT; Schema: arm_offline; Owner: arm_offline
--

ALTER TABLE ONLY orgdata
    ADD CONSTRAINT fk_orgdata_legaladdress FOREIGN KEY (legaladdressid) REFERENCES postaladdress(postaladdressid) MATCH FULL;


--
-- Name: fk_userreq_physicaladdress; Type: FK CONSTRAINT; Schema: arm_offline; Owner: arm_offline
--

ALTER TABLE ONLY userrequisites
    ADD CONSTRAINT fk_userreq_physicaladdress FOREIGN KEY (physicaladdressid) REFERENCES postaladdress(postaladdressid) MATCH FULL;


--
-- Name: fk_userreq_registraddress; Type: FK CONSTRAINT; Schema: arm_offline; Owner: arm_offline
--

ALTER TABLE ONLY userrequisites
    ADD CONSTRAINT fk_userreq_registraddress FOREIGN KEY (registrationaddressid) REFERENCES postaladdress(postaladdressid) MATCH FULL;