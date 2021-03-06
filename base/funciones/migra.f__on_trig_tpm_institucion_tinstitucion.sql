--------------- SQL ---------------

CREATE OR REPLACE FUNCTION migra.f__on_trig_tpm_institucion_tinstitucion (
  v_operacion varchar,
  p_codigo varchar,
  p_id_institucion integer,
  p_id_persona integer,
  p_cargo_representante varchar,
  p_casilla varchar,
  p_celular1 varchar,
  p_celular2 varchar,
  p_codigo_banco varchar,
  p_direccion varchar,
  p_doc_id varchar,
  p_email1 varchar,
  p_email2 varchar,
  p_es_banco varchar,
  p_estado_reg varchar,
  p_fax varchar,
  p_fecha_mod timestamp,
  p_fecha_reg timestamp,
  p_id_usuario_mod integer,
  p_id_usuario_reg integer,
  p_nombre varchar,
  p_observaciones text,
  p_pag_web varchar,
  p_telefono1 varchar,
  p_telefono2 varchar
)
RETURNS text AS
$body$
/*
						Function:  Para migracion de la tabla param.tgestion
						Fecha Creacion:  February 8, 2013, 4:26 pm
						Autor: autogenerado (ADMINISTRADOR DEL SISTEMA )
						
						*/
						
						DECLARE
						
						BEGIN
						
						    if(v_operacion = 'INSERT') THEN
						
						          INSERT INTO 
						            PARAM.tinstitucion (
						codigo,
						id_institucion,
						id_persona,
						cargo_representante,
						casilla,
						celular1,
						celular2,
						codigo_banco,
						direccion,
						doc_id,
						email1,
						email2,
						es_banco,
						estado_reg,
						fax,
						fecha_mod,
						fecha_reg,
						id_usuario_mod,
						id_usuario_reg,
						nombre,
						observaciones,
						pag_web,
						telefono1,
						telefono2)
				VALUES (
						p_codigo,
						p_id_institucion,
						p_id_persona,
						p_cargo_representante,
						p_casilla,
						p_celular1,
						p_celular2,
						p_codigo_banco,
						p_direccion,
						p_doc_id,
						p_email1,
						p_email2,
						p_es_banco,
						p_estado_reg,
						p_fax,
						p_fecha_mod,
						p_fecha_reg,
						p_id_usuario_mod,
						p_id_usuario_reg,
						p_nombre,
						p_observaciones,
						p_pag_web,
						p_telefono1,
						p_telefono2);

						       
							    ELSEIF  v_operacion = 'UPDATE' THEN
						              
                                  --chequear si ya existe el auxiliar si no sacar un error
                                 IF  not EXISTS(select 1 
                                   from  PARAM.tinstitucion 
                                   where id_institucion=p_id_institucion) THEN
                                             
                                    raise exception 'No existe el registro que desea modificar';
                                                  
                                 END IF;
                                
                                
                                
                                 UPDATE 
						                  PARAM.tinstitucion  
						                SET						 codigo=p_codigo
						 ,id_persona=p_id_persona
						 ,cargo_representante=p_cargo_representante
						 ,casilla=p_casilla
						 ,celular1=p_celular1
						 ,celular2=p_celular2
						 ,codigo_banco=p_codigo_banco
						 ,direccion=p_direccion
						 ,doc_id=p_doc_id
						 ,email1=p_email1
						 ,email2=p_email2
						 ,es_banco=p_es_banco
						 ,estado_reg=p_estado_reg
						 ,fax=p_fax
						 ,fecha_mod=p_fecha_mod
						 ,fecha_reg=p_fecha_reg
						 ,id_usuario_mod=p_id_usuario_mod
						 ,id_usuario_reg=p_id_usuario_reg
						 ,nombre=p_nombre
						 ,observaciones=p_observaciones
						 ,pag_web=p_pag_web
						 ,telefono1=p_telefono1
						 ,telefono2=p_telefono2
						 WHERE id_institucion=p_id_institucion;

						       
						       ELSEIF  v_operacion = 'DELETE' THEN
						       
						          --chequear si ya existe el auxiliar si no sacar un error
                                 IF  not EXISTS(select 1 
                                   from  PARAM.tinstitucion 
                                   where id_institucion=p_id_institucion) THEN
                                             
                                    raise exception 'No existe el registro que desea eliminar';
                                                  
                                 END IF;
                                 
                                 
                                 
                                 DELETE FROM 
						              PARAM.tinstitucion
 
						              						 WHERE id_institucion=p_id_institucion;

						       
						       END IF;  
						  
						 return 'true';
						
						-- statements;
						--EXCEPTION
						--WHEN exception_name THEN
						--  statements;
						END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;