--------------- SQL ---------------

CREATE OR REPLACE FUNCTION migra.f_migrar_cbte_a_regionales (
  p_id_int_comprobante integer,
  p_id_plan_pago integer
)
RETURNS varchar AS
$body$
/*
Autor: RAC
Fecha: 02/09/2015
Descripción: Migrar el comprobante Temporal generado en PXP central a PXP en as estaciones internacionales
*/
DECLARE

    v_nombre_funcion        text;
    v_cadena_cnx 			varchar;
    v_resp 					varchar;
    v_sql 					varchar;
    v_rec 					record;
    v_dat 					record;
    v_cont 					integer;
    v_id_depto_lb			integer;
    
    va_id_int_transaccion integer[]; 
    va_id_cuenta integer[]; 
    va_id_auxiliar integer[]; 
    va_id_centro_costo integer[];
    va_id_orden_trabajo integer[];
    va_id_partida integer[];
    va_id_partida_ejecucion integer[];
    va_id_int_transaccion_fk integer[];
    va_glosa varchar[];
    va_importe_debe numeric[];
    va_importe_haber numeric[];
    va_importe_recurso numeric[];
    va_importe_gasto numeric[];
    va_id_uo integer[];
	va_id_ep integer[];    
    v_id_depto_endesis  			integer;    
    v_tipo_cambio 					numeric;    
    va_id_cuenta_bancaria 			integer[];
    va_nombre_cheque_trans 			varchar[];
    va_nro_cheque 					integer[];
    va_tipo 						varchar[];
    va_id_libro_bancos 				integer[];
    va_id_cuenta_bancaria_endesis 	integer[];    
    v_glosa1 						varchar;
    v_glosa2 						varchar;
    v_id_depto_libro  				integer;
    v_id_depto_origen_pxp			integer;
    v_conexion 						varchar;

BEGIN


   v_nombre_funcion:='migra.f_migrar_cbte_a_regionales';

	--Verificación de existencia de parámetro
    if not exists(select 1 from conta.tint_comprobante
    			where id_int_comprobante = p_id_int_comprobante) then
    	raise exception 'Migración de comprobante no realizada: comprobante inexistente';
    end if;
    
    --Obtiene los datos del comprobante
    select  
      cbte.id_int_comprobante, 
      cbte.id_clase_comprobante, 
      cbte.id_int_comprobante_fks, 
      cbte.id_subsistema, 
      cbte.id_depto, 
      cbte.id_moneda, 
      cbte.id_periodo, 
      cbte.nro_cbte, 
      cbte.momento, 
      cbte.glosa1, 
      cbte.glosa2, 
      cbte.beneficiario, 
      cbte.tipo_cambio, 
      cbte.id_funcionario_firma1, 
      cbte.id_funcionario_firma2, 
      cbte.id_funcionario_firma3, 
      cbte.fecha,
      cbte.nro_tramite,
      cbte.id_usuario_reg,
      cla.codigo as codigo_clase_cbte,
      cbte.momento_comprometido,
      cbte.momento_ejecutado,
      cbte.momento_pagado,
      cbte.id_depto_libro,
      cbte.id_usuario_reg,
      cbte.id_plantilla_comprobante
    into
    	v_rec
    from conta.tint_comprobante cbte
    inner join conta.tclase_comprobante cla
	on cla.id_clase_comprobante = cbte.id_clase_comprobante
    where cbte.id_int_comprobante = p_id_int_comprobante;
    
    
    v_id_depto_origen_pxp = v_rec.id_depto;
    
   
       
    
    
    -- Obtiene los datos de la transacción
    v_cont = 1;
    for v_dat in (select
                  tra.id_int_transaccion,
                  tra.id_cuenta, 
                  tra.id_auxiliar, 
                  tra.id_centro_costo,
                  tra.id_orden_trabajo,
                  tra.id_partida,
                  tra.id_partida_ejecucion,
                  tra.id_int_transaccion_fk, 
                  tra.glosa,
                  tra.importe_debe,
                  tra.importe_haber, 
                  tra.importe_recurso, 
                  tra.importe_gasto,
                  tra.importe_debe_mb, 
                  tra.importe_haber_mb, 
                  tra.importe_recurso_mb, 
                  tra.importe_gasto_mb,
                  cco.id_uo,
                  cco.id_ep,
                  coalesce(tra.id_cuenta_bancaria,-1) as id_cuenta_bancaria,
                  coalesce(tra.nombre_cheque_trans,'S/N') as nombre_cheque_trans,
                  coalesce(tra.nro_cheque,-1) as nro_cheque,
                  tra.forma_pago::varchar as tipo,
                  coalesce(tra.id_cuenta_bancaria_mov,-1) as id_libro_bancos,
                  coalesce(cb.id_cuenta_bancaria,-1) as id_cuenta_bancaria_endesis
                  from conta.tint_transaccion tra
                  inner join param.tcentro_costo cco
                  on cco.id_centro_costo = tra.id_centro_costo
                  inner join conta.tcuenta cta
                  on cta.id_cuenta=tra.id_cuenta
      			  left join migra.tts_cuenta_bancaria cb
                  on cb.id_cuenta_bancaria_pxp=tra.id_cuenta_bancaria and cb.id_gestion=cta.id_gestion       
                  where tra.id_int_comprobante = p_id_int_comprobante) loop
                  
    	va_id_int_transaccion[v_cont]=v_dat.id_int_transaccion;
        va_id_cuenta[v_cont]=v_dat.id_cuenta;
        va_id_auxiliar[v_cont]=v_dat.id_auxiliar;
        va_id_centro_costo[v_cont]=v_dat.id_centro_costo;
        va_id_orden_trabajo[v_cont]=COALESCE(v_dat.id_orden_trabajo,0);
        va_id_partida[v_cont]=v_dat.id_partida;
        va_id_partida_ejecucion[v_cont]=v_dat.id_partida_ejecucion;
        va_id_int_transaccion_fk[v_cont]=v_dat.id_int_transaccion_fk;
        va_importe_debe[v_cont]=v_dat.importe_debe;
        va_importe_haber[v_cont]=v_dat.importe_haber;
        va_importe_recurso[v_cont]=v_dat.importe_recurso;
        va_importe_gasto[v_cont]=v_dat.importe_gasto;
        va_id_uo[v_cont]=v_dat.id_uo;
        va_id_ep[v_cont]=v_dat.id_ep;
        
        va_id_cuenta_bancaria[v_cont]=v_dat.id_cuenta_bancaria;
        va_nombre_cheque_trans[v_cont]=v_dat.nombre_cheque_trans;
        va_nro_cheque[v_cont]=v_dat.nro_cheque;
        va_tipo[v_cont]= COALESCE(v_dat.tipo,'');
        va_id_libro_bancos[v_cont]=v_dat.id_libro_bancos;
        va_id_cuenta_bancaria_endesis[v_cont]=v_dat.id_cuenta_bancaria_endesis;
        va_glosa[v_cont]=COALESCE(v_dat.glosa,'--');
       
        
        v_cont = v_cont + 1;
   	end loop;
    
    
    
    
    v_glosa1 = v_rec.glosa1;
    v_glosa2 = v_rec.glosa2;
    
   
    --Forma la llamada para enviar los datos del comprobante al servidor destino
    v_sql:='select migra.f_recibir_cbte_central('||
                v_rec.id_int_comprobante ||','|| --p_id_int_comprobante,
                 v_rec.id_plantilla_comprobante ||','|| --p_id_plantilla_comprobante,
                
                v_rec.id_clase_comprobante ||','||
                'null' ||','||
                v_rec.id_subsistema ||','||
                v_rec.id_depto ||','||
                coalesce(v_rec.id_depto_libro::varchar,'null')||','||
                coalesce(v_id_depto_origen_pxp::varchar,'null')||','||
                v_rec.id_moneda ||','||
                v_rec.id_periodo ||','||
                ''''||coalesce(v_rec.nro_cbte,'') ||''','||
                ''''||coalesce(v_rec.momento,'') ||''','||
                ''''||coalesce(trim(v_glosa1),'') ||''','||
                ''''||coalesce(trim(v_glosa2),'') ||''','||
                ''''||coalesce(v_rec.beneficiario,'') ||''','||
                coalesce(v_tipo_cambio,0) ||','||
                'null' ||','|| --id_funcionario_firma1
                'null' ||','|| --id_funcionario_firma2
                'null' ||','|| --id_funcionario_firma3
                ''''||v_rec.fecha ||''','||
                ''''||coalesce(v_rec.nro_tramite,'') ||''',
                '||COALESCE(('array['|| array_to_string(va_id_int_transaccion, ',')||']::integer[]')::varchar,'NULL::integer[]')||',
                '||COALESCE(('array['|| array_to_string(va_id_cuenta, ',')||']::integer[]')::varchar,'NULL::integer[]')||',
                '||COALESCE(('array['|| array_to_string(va_id_auxiliar, ',')||']::integer[]')::varchar,'NULL::integer[]')||',
                '||COALESCE(('array['|| array_to_string(va_id_centro_costo, ',')||']::integer[]')::varchar,'NULL::integer[]')||',
                
                '||COALESCE(('array['|| pxp.f_iif(array_to_string(va_id_orden_trabajo, ',')='','null',array_to_string(va_id_orden_trabajo, ','))||']::integer[]')::varchar,'NULL::integer[]')||',
                
                '||COALESCE(('array['|| array_to_string(va_id_partida, ',')||']::integer[]')::varchar,'NULL::integer[]')||', 
                '||COALESCE(('array['|| pxp.f_iif(array_to_string(va_id_partida_ejecucion, ',')='','null',array_to_string(va_id_partida_ejecucion, ','))||']::integer[]')::varchar,'NULL::integer[]')||',
                '||COALESCE(('array['''||array_to_string(va_glosa, ''',''') ||''']::varchar[]')::varchar,'NULL::varchar[]')||', 
                '||COALESCE(('array['|| array_to_string(va_importe_debe, ',')||']::numeric[]')::varchar,'NULL::numeric[]')||',
                '||COALESCE(('array['|| array_to_string(va_importe_haber, ',')||']::numeric[]')::varchar,'NULL::numeric[]')||',
                '||COALESCE(('array['|| array_to_string(va_importe_recurso, ',')||']::numeric[]')::varchar,'NULL::numeric[]')||',
                '||COALESCE(('array['|| array_to_string(va_importe_gasto, ',')||']::numeric[]')::varchar,'NULL::numeric[]')||','||
                v_rec.id_usuario_reg ||','||
                ''''||coalesce(v_rec.codigo_clase_cbte,'') ||''','||'
                '||COALESCE(('array['|| array_to_string(va_id_uo, ',')||']::integer[]')::varchar,'NULL::integer[]')||',
                '||COALESCE(('array['|| array_to_string(va_id_ep, ',')||']::integer[]')::varchar,'NULL::integer[]')||','||
                ''''||coalesce(v_rec.momento_comprometido,'') ||''','||
                ''''||coalesce(v_rec.momento_ejecutado,'') ||''','||
                ''''||coalesce(v_rec.momento_pagado,'') ||''','
                
                ||COALESCE(('array['|| array_to_string(va_id_cuenta_bancaria, ',')||']::integer[]')::varchar,'NULL::integer[]')||', 
                '||COALESCE(('array['''|| array_to_string(va_nombre_cheque_trans, ''',''')||''']::varchar[]')::varchar,'NULL::varchar[]')||', 
                '||COALESCE(('array['|| array_to_string(va_nro_cheque, ',')||']::integer[]')::varchar,'NULL::integer[]')||', 
                '||COALESCE(('array['''|| array_to_string(va_tipo, ''',''')||''']::varchar[]')::varchar,'NULL::varchar[]')||', 
                '||COALESCE(('array['|| array_to_string(va_id_libro_bancos, ',')||']::integer[]')::varchar,'NULL::integer[]')||',
                '||COALESCE(('array['|| array_to_string(va_id_cuenta_bancaria_endesis, ',')||']::integer[]')::varchar,'NULL::integer[]')||')'; 
                
                
    --recuperar datos de la estacion            
 	
    select 
       pp.id_depto_lb
    into 
       v_id_depto_lb
    from tes.tplan_pago pp 
    where pp.id_plan_pago = p_id_plan_pago;
    
    
            
    v_conexion =  migra.f_crear_conexion(v_id_depto_lb,'tes.testacion');
     
     --raise exception 'sss %', p_id_int_comprobante;
    
    IF v_conexion is null or v_conexion = '' THEN
      raise exception 'No se pudo conectar con la base de datos destino';
      
    END IF;
    --Ejecuta la fucion que recibe el CBTE en la estacion destino .....
    perform * from dblink(v_conexion, v_sql, true) as (respuesta varchar);
    
            
   select * into v_resp from migra.f_cerrar_conexion(v_conexion,'exito');
    
    
    --Devuelve la respuesta
    return 'Hecho';


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