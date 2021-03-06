--------------- SQL ---------------

CREATE OR REPLACE FUNCTION migra.f_obtener_cadena_conexion (
)
RETURNS varchar AS
$body$
/**************************************************************************
 SISTEMA:		Sistema de Presupuestos
 FUNCION: 		migra.f_obtener_cadena_conexion
 DESCRIPCION:   Funcion que recupera los datos de conexion al servidor remoto
 AUTOR: 		Gonzalo Sarmiento Sejas
 FECHA:	        13-03-2013
 COMENTARIOS:	
***************************************************************************/
DECLARE

v_host varchar;
v_puerto varchar;
v_dbname varchar;
p_user varchar;
v_password varchar;
v_sincronizar varchar; 
v_resp varchar;
v_nombre_funcion varchar;
 
BEGIN


 v_nombre_funcion =  'migra.f_obtener_cadena_conexion';

  v_host=pxp.f_get_variable_global('sincroniza_ip');
  v_puerto=pxp.f_get_variable_global('sincroniza_puerto');  
  v_dbname=pxp.f_get_variable_global('sincronizar_base');
  p_user=pxp.f_get_variable_global('sincronizar_user');
  v_password=pxp.f_get_variable_global('sincronizar_password');
  v_sincronizar=pxp.f_get_variable_global('sincronizar');

   IF v_sincronizar = 'false'  THEN
     
     raise exception 'La sincronizacion esta deshabilitada. Verifique la configuración en la tabla de variables globales';
   
   END IF;

  /*
  v_host='192.168.1.108';
  v_puerto='5432';
  v_dbname='dbendesis';
  p_user='postgres';
  v_password='postgres';*/


  RETURN 'hostaddr='||v_host||' port='||v_puerto||' dbname='||v_dbname||' user='||p_user||' password='||v_password; 

   
EXCEPTION
					
	WHEN OTHERS THEN
			v_resp='';
			v_resp = pxp.f_agrega_clave(v_resp,'mensaje',SQLERRM);
			v_resp = pxp.f_agrega_clave(v_resp,'codigo_error',SQLSTATE);
			v_resp = pxp.f_agrega_clave(v_resp,'procedimientos',v_nombre_funcion);
			raise exception '%',v_resp;
END;
$body$
LANGUAGE 'plpgsql'
VOLATILE
CALLED ON NULL INPUT
SECURITY INVOKER
COST 100;