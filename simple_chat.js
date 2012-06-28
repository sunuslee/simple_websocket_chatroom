function init() {
    admin_name = 'sunussys'
    function showMsg(string) {
        var recvMsgarea = document.getElementById("recvMsgarea");
        recvMsgarea.value += ('\n' + string);
        recvMsgarea.scrollTop = 99999;
    }

    var Socket = "MozWebSocket" in window ? MozWebSocket : WebSocket;
    var ws = new Socket("ws://localhost:8080/");
        ws.onmessage = function(evt) { showMsg(evt.data); };
        ws.onclose = function() { showMsg("socket closed"); };
        ws.onopen = function() {
            showMsg("connected...");
        };

        window.onload = function() {
            var btn_send = document.getElementById('btn-send');
            btn_send.addEventListener("click", function () {
                var text = document.getElementById('sendMsgarea').value;
                if(text.length > 0) {
                    var to = document.getElementById('to').value;
                    var from = document.getElementById('from').value;
                    ws.send(from + '|' + to + '|:' + text);
                    document.getElementById('sendMsgarea').value='';
                    showMsg('\nYou:\n' + text);
                }
            });
            var btn_start = document.getElementById('btn-start');
            btn_start.addEventListener("click", function() {
                var btn_start = document.getElementById('from');
                var from = btn_start.value;
                if(from != '')  {
                    ws.send(from + '|' + admin_name + '||:' + 'login');
                    alert('welcome\n' + from);
                    document.getElementById('btn-start').disabled = true;
                    document.getElementById('from').disabled = true;
                }
            });
        };
};

init();
