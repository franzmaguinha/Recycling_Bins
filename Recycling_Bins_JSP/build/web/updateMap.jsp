<%-- 
    Document   : index
    Created on : Jun 1, 2016, 10:15:45 AM
    Author     : frz19x
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE HTML PUBLIC “-//W3C//DTD HTML 4.01 Transitional//EN”
“http://www.w3.org/TR/html4/loose.dtd”>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/sql" prefix="sql"%>

<!DOCTYPE html>
<html>
<head>
    <link href="estilo.css" rel="stylesheet" type="text/css"/>
    <title>Recycling Bins</title>
    <link rel="icon" href="https://raw.githubusercontent.com/asdfrz/PDM/master/Proyectov2.0/Proyectov1.0/app/src/main/res/drawable/ic_recycling.png">
    <% 
        java.sql.Connection con=null;
        java.sql.Statement s=null;
        java.sql.ResultSet rs=null;
        java.sql.PreparedStatement pst=null;
        String tipo = request.getParameter("D1");
        String ciudad = request.getParameter("D2");

        try{

        Class.forName("com.mysql.jdbc.Driver");
            con=DriverManager.getConnection("jdbc:mysql://127.0.0.1/recyclingbins","root","asd");
            s = con.createStatement();
        }catch(ClassNotFoundException cnfex){
            cnfex.printStackTrace();
        }
        String sql = "SELECT nombre,lat,lng FROM basurero;";
        if(ciudad==null){
            if(tipo.equalsIgnoreCase("Tipo de Basura")==false&&tipo!=null){
                sql = "select * from basurero inner join tipobasurero on id=idbasurero where idtipo=(select id from tipo where tipo='"+tipo+"');";
            }
        }
        if(tipo==null){
            if(ciudad.equalsIgnoreCase("Distrito")==false&&ciudad!=null){
                sql ="select * from basurero inner join ubicacion on id=idbasurero where idmun=(select id from municipalidad where nombre='"+ciudad+"');";
            }
        }
        try{
        rs = s.executeQuery(sql);
    %>
    <%
        }
        catch(Exception e){e.printStackTrace();}
    %>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyCxj_VOzI9wYX08kjvowXAYSJa9hIWFCR0" type="text/javascript"></script>
    <script language="javascript">
        
        <sql:setDataSource var="snapshot" driver="com.mysql.jdbc.Driver"
            url="jdbc:mysql://127.0.0.1/recyclingbins"
            user="root"  password="asd"/>
        function initialize() {
            var centro = new google.maps.LatLng(-12.0451952,-77.0321625);
            var positions = [];
            var names = [];
            var markers = [];
            var infowindows = [];
            var mapProp = {
                center: centro,
                zoom:11,
                mapTypeId:google.maps.MapTypeId.ROADMAP
            };
            var map=new google.maps.Map(document.getElementById("googleMap"),mapProp);

            var i=0;

            <%
            while( rs.next() ){
            %>
                names[i]="<%= rs.getString("nombre") %>";
                positions[i]=new google.maps.LatLng(<%= rs.getString("lat") %>, <%= rs.getString("lng") %>);
                    i++;
                <%
            }
            %>
            for(i=0;i<positions.length;i++){
                markers[i] = new google.maps.Marker({
                    position: positions[i],
                    map:map,
                    title: "Municipalidad de " + names[i]
                });
            }
            for(i=0;i<names.length;i++){
                infowindows[i] = new google.maps.InfoWindow({
                    content: "Municipalidad de " + names[i]
                });
            }
            for(i=0;i<positions.length;i++){
                markers[i].addListener('click',function(){
                    infowindows[i].open(map, markers[i])          
                });
            }
        }
        google.maps.event.addDomListener(window, 'load', initialize);
    </script>
</head>

<body>
    <div id="bienvenida">
        <h2>Recycling Bins</h2>
    </div>
    
    <ul>
        <li><a href="index.jsp">Inicio</a></li>
        <li><a href="listado.jsp">Lista de Centros</a></li>
        <li><a href="login.jsp">Registro</a></li>
    </ul>

    
    <div id="contenedor">
    <center>
        <sql:query dataSource="${snapshot}" var="tipos">
            SELECT tipo from tipo;
        </sql:query>
        <form name="actualizar" method="post" action="updateMap.jsp">
            <p>Selecciona un tipo 
                <select name="D1" size="1">
                    <option><c:out value="Tipo de Basura"/></option>
                    <c:forEach var="row" items="${tipos.rows}">
                        <option value="${row.tipo}"><c:out value="${row.tipo}"/></option>
                    </c:forEach>
                </select>
            <input type="submit" value="Update" name="update"/></p>
        </form>
        
        <sql:query dataSource="${snapshot}" var="municipalidad">
            SELECT nombre from municipalidad;
        </sql:query>
        <form name="actualizar" method="post" action="updateMap.jsp">
            <p>Selecciona un distrito
                <select name="D2" size="1">
                    <option><c:out value="Distrito"/></option>
                    <c:forEach var="row" items="${municipalidad.rows}">
                        <option value="${row.nombre}"><c:out value="${row.nombre}"/></option>
                    </c:forEach>
                </select>
            <input type="submit" value="Update" name="update"/></p>
        </form>
    </center>
    
    <center>
        <div id="googleMap" style="width:100%;height:70%"></div>
    </center>
    
    </div>
</body>

</html>