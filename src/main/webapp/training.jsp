<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<html>
<head>
    <title></title>
    <link type="text/css" rel="stylesheet" href="<c:url value="css/layout.css"/>">
    <script type="text/javascript" src="<c:url value="js/jquery-1.7.2.min.js"/>"></script>
    <script type='text/javascript' src='<c:url value="js/ajaxfileupload.js"/>'></script>
    <script type='text/javascript' src='<c:url value="js/modal.popup.js"/>'></script>
    <script type='text/javascript' src='<c:url value="js/flotr2.min.js"/>'></script>
    <link rel="stylesheet" type="text/css" href="<c:url value="css/ajaxfileupload.css"/>"/>
    <link rel="stylesheet" type="text/css" href="<c:url value="css/flotr.css"/>"/>
</head>
<body style="width: 100%">
<div style="width:1353px; margin: 0px auto;">
    <div id="header">
        <h1><fmt:message key="application.title"/></h1>
        <img src="<c:url value="img/blogo.jpg"/>" alt="logo">
    </div>
    <img id="loading" style="display:none;position: fixed;left: 50%;top: 20%" src="<c:url value="img/loading.gif"/>"
         alt="loading">
    <ul id="top-navigation">
        <li><a href="<c:url value="index.do"/>">Benchmark</a></li>
        <li><a class="active" href="<c:url value="index.do?training"/>">Training</a></li>
    </ul>
    <div id="container">

        <div id="order-creation">
            <form action="" id="orderForm">

                <div class="orderInput">
                    <button style="width:150px;" onclick="startPreOpening();return false;"><fmt:message key="start_preopening"/></button>
                    <button style="width:150px;" onclick="startTrading();return false;"><fmt:message key="start_trading"/></button>
                    <br>
                    <button style="width:150px;" onclick="sendCommand('stop');return false;"><fmt:message key="stop_process"/></button>
                    <button style="width:150px;" onclick="sendCommand('restart');return false;"><fmt:message key="restart_process"/></button>
                </div>


                <div class="orderInput">
                    <label for="orderSide"><fmt:message key="order_side"/>:</label>
                    <select id="orderSide">
                        <option value="BUY"><fmt:message key="buy"/></option>
                        <option value="SELL"><fmt:message key="sell"/></option>
                    </select>
                </div>
                <div class="orderInput">
                    <label for="price"><fmt:message key="price"/>:</label>
                    <input style="width: 50px;" id="price" name="price" type="text" class="integer"/>
                </div>
                <div class="orderInput">
                    <label for="subscriberPriority"><fmt:message key="subscriber_priority"/>:</label>
                    <input style="width: 50px;" id="subscriberPriority" name="subscriberPriority" type="text" class="integer"/>
                </div>
                <div class="orderInput">
                    <label for="quantity"><fmt:message key="quantity"/>:</label>
                    <input style="width: 50px;" id="quantity" name="quantity" type="text" class="integer"/>
                </div>
                <div class="orderInput">
                    <label for="tradeCost"><fmt:message key="trade_cost"/>:</label>
                    <input style="width: 50px;" id="tradeCost" name="tradeCost" type="text" class="integer"/>
                </div>

                <div class="orderInput">
                    <button onclick="addOrder();return false;"><fmt:message key="add_order"/></button>
                </div>

            </form>
        </div>
        <script type="text/javascript">
            function startPreOpening() {
                $.ajax({
                    type:"GET",
                    dataType:"text",
                    url:"<c:url value="command.do?action=startPreOpening"/>"
                }).done(function (data) {
                    alert(data);
                });
            }

            function startTrading() {
                $.ajax({
                    type:"GET",
                    dataType:"text",
                    url:"<c:url value="command.do?action=startTrading"/>"
                }).done(function (data) {
                    alert(data);
                });
            }

            var addedOrders = [];
            function addOrder() {
                var values = {};
                values['orderSide'] = $("#orderSide option:selected")[0].value;
                $.each($('#orderForm :input').serializeArray(), function (i, field) {
                    values[field.name] = field.value;
                });

                $.ajax(
                    {
                        type:"GET",
                        dataType:"text",
                        data:values,
                        url:"<c:url value="command.do?action=putOrder"/>"
                    }).done(function (data) {
                        alert(data);
                            addedOrders.push(data);
/*
                        getQueues();
                        getTrades();
*/
                    });

                return false;
            }

            function getQueues(){
                $.getJSON(
                "<c:url value="index.do?queues"/>",
                function (data) {
                    for(var i = 0; i < 5; i++){
                        for(var j = 0; j < 4; j++){
                            $("#buyQueue tr")[i+1].cells[j].innerHTML = '';
                            $("#sellQueue tr")[i+1].cells[j].innerHTML = '';
                        }
                    }

                    $.each(data.buyQueues, function (i, order){
                        if(addedOrders.indexOf(order.orderCodeStr) < 0){
                            $("#buyQueue tr")[i+1].cells[0].style.color = "#FF0000";
                            $("#buyQueue tr")[i+1].cells[0].style.border = "1px solid #000000";
                        }else{
                            $("#buyQueue tr")[i+1].cells[0].style.color = "#000000";
                        }
                        $("#buyQueue tr")[i+1].cells[0].innerHTML = (order.orderCodeStr);
                        $("#buyQueue tr")[i+1].cells[1].innerHTML = (order.price);
                        $("#buyQueue tr")[i+1].cells[2].innerHTML = (order.subscriberPriority);
                        $("#buyQueue tr")[i+1].cells[3].innerHTML = (order.totalQuantity);
                    });
                    $.each(data.sellQueues, function (i, order){
                        if(addedOrders.indexOf(order.orderCodeStr) < 0){
                            $("#sellQueue tr")[i+1].cells[0].style.color = "#FF0000";
                            $("#sellQueue tr")[i+1].cells[0].style.border = "1px solid #000000";
                        }else{
                            $("#sellQueue tr")[i+1].cells[0].style.color = "#000000";
                        }
                        $("#sellQueue tr")[i+1].cells[0].innerHTML = (order.orderCodeStr);
                        $("#sellQueue tr")[i+1].cells[1].innerHTML = (order.price);
                        $("#sellQueue tr")[i+1].cells[2].innerHTML = (order.subscriberPriority);
                        $("#sellQueue tr")[i+1].cells[3].innerHTML = (order.totalQuantity);
                    });
                });
            }

            function getTrades(){
                $.getJSON(
                    "<c:url value="index.do?trades"/>",
                    function (data) {
                        $('#tradesTable tbody').children( 'tr:not(:first)' ).remove();
                        $.each(data.tradeLogLines, function (i, tradeLog){
                            var lineParts = tradeLog.split(" ");
                            var stockId = lineParts[0].split(":")[1];
                            var buyOrderParts = lineParts[1].split(",");
                            var buyOrderCode = buyOrderParts[0].split(":")[1];
                            var buyOrderQuantity = buyOrderParts[2];
                            var buyOrderPrice = buyOrderParts[3];
                            var buyOrderPriority = buyOrderParts[4];

                            var sellOrderParts = lineParts[2].split(",");
                            var sellOrderCode = sellOrderParts[0].split(":")[1];
                            var sellOrderQuantity = sellOrderParts[2];
                            var sellOrderPrice = sellOrderParts[3];
                            var sellOrderPriority = sellOrderParts[4];

                            $('#tradesTable tr:last').after('<tr style="text-align: center; border-bottom: 1px solid"><td>'+stockId+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+buyOrderCode+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+buyOrderQuantity+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+buyOrderPrice+'</td>' +
                                    '<td style="border-bottom: 1px solid; border-left: 1px solid">'+buyOrderPriority+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+sellOrderCode+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+sellOrderQuantity+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+sellOrderPrice+'</td>' +
                                    '<td style="border-bottom: 1px solid">'+sellOrderPriority+'</td></tr>');
                        });
                    });
            }

            function sendCommand(command){
                $.ajax({
                    type:"GET",
                    dataType:"text",
                    url:"<c:url value="command.do?action="/>" + command,
                    success: function(data) {
                        alert(data);
                    }
                });
            }

            setInterval(function () {
                getQueues();
                getTrades();
            }, 500);
        </script>

        <div id="queues">
            <table id="buyQueue" class="queueTable">
                <caption><fmt:message key="buy_queue"/></caption>
                <tr>
                    <th>Order Code</th>
                    <th>Price</th>
                    <th>Subscriber Priority</th>
                    <th>Quantity</th>
                </tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
            </table>
            <table id="sellQueue" class="queueTable">
                <caption><fmt:message key="sell_queue"/></caption>
                <tr>
                    <th>Order Code</th>
                    <th>Price</th>
                    <th>Subscriber Priority</th>
                    <th>Quantity</th>
                </tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
                <tr><td></td><td></td><td></td><td></td></tr>
            </table>
        </div>

        <div id="trades">
            <table id="tradesTable" style="float: right;">
                <caption><fmt:message key="trades"/></caption>
                <tr>
                    <th>Stock Id</th>
                    <th>Buy Order Code</th>
                    <th>Buy Order Quantity</th>
                    <th>Buy Order Price</th>
                    <th style="border-left: 1px solid;">Buy Order Priority</th>
                    <th>Sell Order Code</th>
                    <th>Sell Order Quantity</th>
                    <th>Sell Order Price</th>
                    <th>Sell Order Priority</th>
                </tr>
            </table>

        </div>

    </div>
    <div id="footer" style="float: left;margin-top: 10px;margin-left: 35px;"><fmt:message key="created_by_safa"/></div>
</div>
</body>
</html>