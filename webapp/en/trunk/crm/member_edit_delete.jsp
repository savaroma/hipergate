<%@ page import="com.knowgate.crm.DistributionList,java.util.*,java.io.IOException,java.net.URLDecoder,java.sql.*,com.knowgate.jdc.*,com.knowgate.dataobjs.*,com.knowgate.acl.*,com.knowgate.hipergate.*,com.knowgate.misc.Gadgets" language="java" session="false" %>
<%@ include file="../methods/dbbind.jsp" %>
<%@ include file="../methods/cookies.jspf" %>
<%@ include file="../methods/authusrs.jspf" %>
<%@ include file="../methods/clientip.jspf" %>
<%
/*
  Copyright (C) 2003  Know Gate S.L. All rights reserved.
                      C/Oña, 107 1º2 28050 Madrid (Spain)

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions
  are met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. The end-user documentation included with the redistribution,
     if any, must include the following acknowledgment:
     "This product includes software parts from hipergate
     (http://www.hipergate.org/)."
     Alternately, this acknowledgment may appear in the software itself,
     if and wherever such third-party acknowledgments normally appear.

  3. The name hipergate must not be used to endorse or promote products
     derived from this software without prior written permission.
     Products derived from this software may not be called hipergate,
     nor may hipergate appear in their name, without prior written
     permission.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

  You should have received a copy of hipergate License with this code;
  if not, visit http://www.hipergate.org or mail to info@hipergate.org
*/
  if (autenticateSession(GlobalDBBind, request, response)<0) return;
  
  String id_user = getCookie (request, "userid", null);
  String gu_list = request.getParameter("gu_list");
  String de_list = request.getParameter("de_list");
  String gu_black;
  String a_items[] = Gadgets.split(request.getParameter("checkeditems"), ',');
  
  PreparedStatement oStm;
  DistributionList oLst;
     
  JDCConnection oCon = GlobalDBBind.getConnection("listmember_delete");
  
  try {
    
    // ************************************************
    // [~//Obtener la lista asociada de miembros bloqueados~]
    
    oLst = new DistributionList(oCon, gu_list);
    gu_black = oLst.blackList(oCon);

    oCon.setAutoCommit (false);
    
    oStm = oCon.prepareStatement("DELETE FROM " + DB.k_x_list_members + " WHERE " + DB.gu_list + "=? AND " + DB.tx_email + "=?");

    if (gu_black==null)
    
      for (int i=0;i<a_items.length;i++) {

        // *******************************************
        // [~//Borrar el miembro de la lista principal~]
      
        oStm.setString(1, gu_list);
        oStm.setString(2, a_items[i]);      
        oStm.execute();

      } // next ()
    
    else

      for (int i=0;i<a_items.length;i++) {

        // *******************************************
        // [~//Borrar el miembro de la lista de bloqueados~]

        oStm.setString(1, gu_black);
        oStm.setString(2, a_items[i]);      
        oStm.execute();

        // *******************************************
        // [~//Borrar el miembro de la lista principal~]
      
        oStm.setString(1, gu_list);
        oStm.setString(2, a_items[i]);      
        oStm.execute();

      } // next ()
    
    oStm.close();
    oCon.commit();
    oCon.close("listmember_delete");
  } 
  catch(SQLException e) {
      disposeConnection(oCon,"listmember_delete");
      oCon = null;
      response.sendRedirect (response.encodeRedirectUrl ("../common/errmsg.jsp?title=Error&desc=" + e.getLocalizedMessage() + "&resume=_close"));
    }
  
  if (null==oCon) return;
    
  oCon = null; 

  out.write("<HTML><HEAD><TITLE>Wait...</TITLE><" + "SCRIPT LANGUAGE='JavaScript' TYPE='text/javascript'>window.document.location='member_listing.jsp?selected=" + request.getParameter("selected") + "&subselected=" + request.getParameter("subselected") + "&gu_list=" + gu_list + "&de_list=" + de_list + "'<" + "/SCRIPT" +"></HEAD></HTML>"); 
%>