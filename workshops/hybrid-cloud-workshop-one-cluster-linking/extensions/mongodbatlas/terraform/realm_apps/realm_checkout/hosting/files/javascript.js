
// Retrieve App ID from URL
var hostname = $(location).attr('hostname');
var res = hostname.split(".");
console.log(res[0])

// Initialize Realm client with App ID retrieved from URL
const client = stitch.Stitch.initializeDefaultAppClient(res[0]);

const db = client.getServiceClient(stitch.RemoteMongoClient.factory, 'mongodb-atlas').db('demo');

client.auth.loginWithCredential(new stitch.AnonymousCredential()).catch(err => {
    console.error(err)
});

$(function () {
    // Add order item based upon selection
    $("#addButton").click(function () {
        let value = $("#inputGroupSelect option:selected").text()

        console.log($("#inputGroupSelect option:selected").val())
        if ($("#inputGroupSelect option:selected").val() !== "Choose...") {
            let x = $("#orderItems").children().length
            x++
            console.log(x)
            $("#orderItems").append(
                `<li class="list-group-item">
                    <div class="form-group">
                        <label for="orderItem">Order Item`+x+`</label>
                        <input type="text" class="form-control" id="oid_`+x+`" name="lineItem" value="`+value+`" readonly>
                    </div>
                </li>`
            );
        }
    });

    // Create JSON Order Object and send to database
    $('form').submit(function (event) {
        event.preventDefault();
        if ($(this).valid()) {
            let po = {}
            let lineItems = []
            $(this).serializeArray().forEach((item) => {
                if (item.name === "lineItem") {
                    lineItems.push({ "order": item.value })
                } else {
                    po[item.name] = item.value
                }
            })
            po['lineItems'] = lineItems
            console.log(JSON.stringify(po))
            po['owner_id'] = client.auth.user.id

            db.collection('estore').insertOne(po).then(success => {
                $("#alerts").append(`
                    <div class="alert alert-success mx-auto">
                        <strong>Success!</strong> Order successfully submitted!
                        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>`)
            }).catch(err => {
                console.error(err)
            });
        } else {
            console.log("Form is invalid")
        }

    });
});