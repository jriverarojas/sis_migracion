﻿CREATE OR REPLACE FUNCTION migracion.f_mig_ini_tpm_proyecto_tproyecto (
)
RETURNS boolean AS
$body$
						DECLARE
						 
						g_registros record;
						v_consulta varchar;
						v_res_cone varchar;
						v_cadena_cnx varchar;
						v_resp varchar;
						
						v_cadena_resp varchar[];
						
						BEGIN
						     --funcion para obtener cadena de conexion
							 v_cadena_cnx =  migracion.f_obtener_cadena_con_dblink();
									          
						  
						    --quirta llaves foraneas en el destino
						     v_resp =  (SELECT dblink_connect(v_cadena_cnx));
									            
						     IF(v_resp!='OK') THEN
									            
						        --modificar bandera de fallo  
						         raise exception 'FALLA CONEXION A LA BASE DE DATOS CON DBLINK';
									                 
						     ELSE
						       v_consulta = 'select pxp.f_add_remove_foraneas(''tproyecto'',''PARAM'',''eliminar'')';                   
						       raise notice '%',v_consulta;
						       PERFORM * FROM dblink(v_consulta,true) AS ( xx varchar);
						        v_res_cone=(select dblink_disconnect());
						     END IF;
						
						
						   --consulta los registro de la tabla origen
						    FOR g_registros in (
						        SELECT 
						codigo_proyecto,
						id_proyecto,
						id_usuario,
						codigo_sisin,
						descripcion_proyecto,
						fase_proyecto,
						fecha_registro,
						fecha_ultima_modificacion,
						hora_registro,
						hora_ultima_modificacion,
						id_persona,
						id_proyecto_actif,
						id_usr_mod,
						nombre_corto,
						nombre_proyecto,
						tipo_estudio
FROM 
						          PARAM.tpm_proyecto) LOOP
						        
						        -- inserta en el destino
						      
						            v_cadena_resp = migracion.f_trans_tpm_proyecto_tproyecto(
						            'INSERT',g_registros.codigo_proyecto
					,g_registros.id_proyecto
					,g_registros.id_usuario
					,g_registros.codigo_sisin
					,g_registros.descripcion_proyecto
					,g_registros.fase_proyecto
					,g_registros.fecha_registro
					,g_registros.fecha_ultima_modificacion
					,g_registros.hora_registro
					,g_registros.hora_ultima_modificacion
					,g_registros.id_persona
					,g_registros.id_proyecto_actif
					,g_registros.id_usr_mod
					,g_registros.nombre_corto
					,g_registros.nombre_proyecto
					,g_registros.tipo_estudio
					);	
					
					
						        IF v_cadena_resp[1] = 'FALSE' THEN
					               
					              RAISE NOTICE 'ERROR ->>>  (%),(%) - %   ', v_cadena_resp[3], v_cadena_resp[2], v_cadena_resp[4];
					              
					            END IF; 	
						
						
						
						
						    END LOOP;
						
						     --reconstruye llaves foraneas
						     v_resp =  (SELECT dblink_connect(v_cadena_cnx));
									            
						     IF(v_resp!='OK') THEN
									            
						        --modificar bandera de fallo  
						         raise exception 'FALLA CONEXION A LA BASE DE DATOS CON DBLINK';
									                 
						     ELSE
						       v_consulta = 'select pxp.f_add_remove_foraneas(''tproyecto'',''PARAM'',''insertar'')';                   
						       raise notice '%',v_consulta;
						       PERFORM * FROM dblink(v_consulta,true) AS ( xx varchar);
						        v_res_cone=(select dblink_disconnect());
						     END IF;
						
						RETURN TRUE;
						END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER;