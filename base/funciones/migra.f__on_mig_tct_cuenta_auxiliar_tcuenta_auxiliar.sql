CREATE OR REPLACE FUNCTION migra.f__on_trig_tct_cuenta_auxiliar_tcuenta_auxiliar (
						  v_operacion varchar,p_id_cuenta_auxiliar int4,p_estado_reg varchar,p_fecha_mod timestamp,p_fecha_reg timestamp,p_id_auxiliar int4,p_id_cuenta int4,p_id_usuario_mod int4,p_id_usuario_reg int4)
						RETURNS text AS
						$BODY$

/*
						Function:  Para migracion de la tabla param.tgestion
						Fecha Creacion:  October 29, 2013, 5:53 pm
						Autor: autogenerado (ADMINISTRADOR DEL SISTEMA )
						
						*/
						
						DECLARE
						
						BEGIN
						
						    if(v_operacion = 'INSERT') THEN
						
						          INSERT INTO 
						            CONTA.tcuenta_auxiliar (
						id_cuenta_auxiliar,
						estado_reg,
						fecha_mod,
						fecha_reg,
						id_auxiliar,
						id_cuenta,
						id_usuario_mod,
						id_usuario_reg)
				VALUES (
						p_id_cuenta_auxiliar,
						p_estado_reg,
						p_fecha_mod,
						p_fecha_reg,
						p_id_auxiliar,
						p_id_cuenta,
						p_id_usuario_mod,
						p_id_usuario_reg);

						       
							    ELSEIF  v_operacion = 'UPDATE' THEN
						               UPDATE 
						                  CONTA.tcuenta_auxiliar  
						                SET						 estado_reg=p_estado_reg
						 ,fecha_mod=p_fecha_mod
						 ,fecha_reg=p_fecha_reg
						 ,id_auxiliar=p_id_auxiliar
						 ,id_cuenta=p_id_cuenta
						 ,id_usuario_mod=p_id_usuario_mod
						 ,id_usuario_reg=p_id_usuario_reg
						 WHERE id_cuenta_auxiliar=p_id_cuenta_auxiliar;

						       
						       ELSEIF  v_operacion = 'DELETE' THEN
						       
						         DELETE FROM 
						              CONTA.tcuenta_auxiliar
 
						              						 WHERE id_cuenta_auxiliar=p_id_cuenta_auxiliar;

						       
						       END IF;  
						  
						 return 'true';
						
						-- statements;
						--EXCEPTION
						--WHEN exception_name THEN
						--  statements;
						END;
						$BODY$


						LANGUAGE 'plpgsql'
						VOLATILE
						CALLED ON NULL INPUT
						SECURITY INVOKER
						COST 100;