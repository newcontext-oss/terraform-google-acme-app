#! /usr/bin/env bash

sudo apt-get update
sudo apt-get install -y ruby
sudo gem install rethinkdb  --no-ri --no-rdoc
sudo gem install sinatra  --no-ri --no-rdoc

sudo mkdir -p /opt/acme_corp_web
sudo chown -R ubuntu. /opt/acme_corp_web

cat <<EOF >> /opt/acme_corp_web/config.ru
require './acme_corp_orders_page'
run Sinatra::Application
EOF

cat <<EOF >> /opt/acme_corp_web/acme_corp_orders_page.rb
require 'rethinkdb'
require 'sinatra'
require 'json'

configure do
  set :show_exceptions, false
end

error do
  "<div style='text-align: center; vertical-align: middle;'><h1>500 Error</h1><img src='https://vignette.wikia.nocookie.net/cartooncharacters/images/0/03/21477bplooney-tunes-wile-e-coyote-posters-2007813.jpg/revision/latest/scale-to-width-down/300?cb=20100528115118'></div>"
end

before do
  database_ip = '${db_internal_ip}'

  @rql = RethinkDB::RQL.new
  @connection = @rql.connect(host: database_ip, port: 28015)
end

get '/' do
  erb :index
end

get '/total_revenue.json' do
  begin
    result = @rql.db('data').table('orders').sum{|order| order['amount'] * order['price']}.run(@connection)
  ensure
    @connection.close if @connection
  end

  content_type :json
  result.to_json
end

get '/latest_order.json' do
  begin
    result = @rql.db('data').table('orders').order_by(@rql.desc('purchased_at')).limit(1).run(@connection)
  ensure
    @connection.close if @connection
  end

  content_type :json
  result.first.to_json
end

__END__

@@ index
<html>
<head>
<title>ACME Corporation - Recent Orders</title>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous">
<link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/ui-lightness/jquery-ui.css">
</head>
<body>
<h1>ACME Coporation</h1>
<br>
<div class="container-fluid">
<div class="row">
<div class="col">
<h2 id="total_revenue">Total Revenue: \$0.00</h2>
<div>
<div class="col">
<br>
<br>
<h3>Recent Orders</h3>
<br>
<table class="table table-hover">
  <thead class="thead-light">
    <tr>
      <th scope="col">Purchased At</th>
      <th scope="col">Customer</th>
      <th scope="col">Amount</th>
      <th scope="col">Product</th>
      <th scope="col">Price</th>
    </tr>
  </thead>
  <tbody id="recent_orders">
  </tbody>
</table>
</div>
</div>
</div>
<table class="table">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"></script>
<script>
  function sleep(milliseconds) {
    var start = new Date().getTime();
    for (var i = 0; i < 1e7; i++) {
      if ((new Date().getTime() - start) > milliseconds){
        break;
      }
    }
  }

  function get_latest_order() {
    setInterval(function() {
      sleep(3000);
      \$.getJSON("/latest_order.json", function( order ){
        \$("<tr><td>" + order.purchased_at + "</td><td>" + order.customer + "</td><td>" + order.amount + "</td><td>" + order.product + "</td><td>\$" + parseFloat(order.price, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "\$1,").toString() + "</td></tr>").prependTo("tbody#recent_orders").effect("highlight", {}, 1000);
      }).fail(function() {
        \$('#exampleModal').modal();
      });
    }, 5000);
  }

  function get_total_revenue() {
    setInterval(function() {
      sleep(3000);
      \$.getJSON("/total_revenue.json", function( data ){
        \$("h2#total_revenue").replaceWith("<h2 id=total_revenue>Total Revenue: \$" + parseFloat(data, 10).toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, "\$1,").toString() + "</h2>");
      }).fail(function() {
        \$('#exampleModal').modal();
      });
    }, 5000);
  }

\$(get_latest_order);
\$(get_total_revenue);

</script>

<div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <h3 class="modal-title" id="exampleModalLabel">Error on Data Pull</h3>
        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <div class="modal-body">
        Unable to pull new data, please reload the page and try again.
      </div>
      <div class="modal-footer">
        <a href="/" class="btn btn-primary">Reload</a>
      </div>
    </div>
  </div>
</div>
</body>
</html>
EOF

cat <<EOF >> /tmp/acme_corp_web.service
[Unit]
Description=ACME Corp Orders
After=network.target

[Service]
User=root
WorkingDirectory=/opt/acme_corp_web
ExecStart=/usr/local/bin/rackup -p 80 -o 0.0.0.0

[Install]
WantedBy=multi-user.target
EOF

sudo mv /tmp/acme_corp_web.service /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable acme_corp_web
sudo systemctl start acme_corp_web
