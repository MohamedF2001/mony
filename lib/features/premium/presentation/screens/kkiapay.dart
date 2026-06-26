import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/kkiapay_flutter_sdk.dart';

void kkiapayPayment(BuildContext context, {required int amount, required Function() onSuccess}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => KKiaPay(
        amount: amount,
        sandbox: true,
        apikey: "22360a90652f11efbf02478c5adba4b8",
        callback: (response, context) {
          debugPrint('Payment Response: $response');
          if (response['status'] == PAYMENT_SUCCESS) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiement réussi !')),
            );
            onSuccess();
          } else if (response['status'] == PAYMENT_CANCELLED) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Paiement annulé')),
            );
          }
        },
        countries: ["BJ", "CI", "SN", "TG"],
        paymentMethods: ["momo", "card"],
      ),
    ),
  );
}

void callback(response, context) {
  debugPrint('Payment Response: $response');
  switch (response['status']) {
    case PAYMENT_CANCELLED:
      debugPrint(PAYMENT_CANCELLED);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PAYMENT_CANCELLED),
      ));
      break;

    case PENDING_PAYMENT:
      debugPrint(PENDING_PAYMENT);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PENDING_PAYMENT),
      ));
      break;

    case PAYMENT_INIT:
      debugPrint(PAYMENT_INIT);
      debugPrint('Request Data: ${response['requestData']}');
      //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //content: Text(PAYMENT_INIT),
      //));
      break;

    case PAYMENT_SUCCESS:
      debugPrint(PAYMENT_SUCCESS);
      debugPrint('Transaction ID: ${response['transactionId']}');
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(PAYMENT_SUCCESS),
      ));
      /* Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessScreen(
            amount: response['requestData']['amount'],
            transactionId: response['transactionId'],
          ),
        ),
      ); */
      break;

    default:
      debugPrint(UNKNOWN_EVENT);
      break;
  }
}

final kkiapay = KKiaPay(
  amount: 10,
  sandbox: true,
  apikey: "22360a90652f11efbf02478c5adba4b8",
  callback: callback,
  countries: ["BJ", "TG"],
  paymentMethods: ["momo"],
);

final kkiapayOnlyAccept = KKiaPay(
  amount: 25,
  sandbox: true,
  apikey: "22360a90652f11efbf02478c5adba4b8",
  callback: callback,
  countries: ["NE", "CI", "SN", "TG", "BJ"],
  paymentMethods: ["momo", "wallet", "card"],
);

final kkiapayOnlyExclude = KKiaPay(
  amount: 3,
  sandbox: false,
  apikey: "your_api_key_here",
  callback: callback,
  countries: ["BJ"],
  paymentMethods: ["momo"],
);

final kkiapayCountrySpecific = KKiaPay(
  amount: 5,
  sandbox: false,
  apikey: "your_api_key_here",
  callback: callback,
  countries: ["TG", "BJ"],
  paymentMethods: ["momo"],
);

final kkiapayNoProviders = KKiaPay(
  amount: 4,
  sandbox: true,
  apikey: "your_api_key_here",
  callback: callback,
  paymentMethods: ["momo", "card"],
);

class KkiapaySample extends StatelessWidget {
  const KkiapaySample({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child:

      ButtonTheme(
        minWidth: 500.0,
        height: 100.0,
        child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(const Color(0xff222F5A)),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: const Text(
            'Pay hNow',
            style: TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => kkiapayOnlyAccept),
            );
          },
        ),
      ),

      /*SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ButtonTheme(
                minWidth: 500.0,
                height: 80.0,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(const Color(0xff222F5A)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    'Accept: Wave,MTN,Moov | Exclude: Orange\n(All Countries)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => kkiapay),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              ButtonTheme(
                minWidth: 500.0,
                height: 80.0,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(const Color(0xff4E6BFC)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    'Accept: Airtel\n(NE only)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => kkiapayOnlyAccept),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              ButtonTheme(
                minWidth: 500.0,
                height: 80.0,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(const Color(0xffF11C33)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    'Exclude: Celtiis(BJ, TG only)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => kkiapayOnlyExclude),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              ButtonTheme(
                minWidth: 500.0,
                height: 80.0,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(const Color(0xff6f42c1)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    'Country-Specific: moov-tg\n(Togo only)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => kkiapayCountrySpecific),
                    );
                  },
                ),
              ),
              const SizedBox(height: 15),
              ButtonTheme(
                minWidth: 500.0,
                height: 80.0,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(const Color(0xff28a745)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    'No Provider Restrictions\n(BJ, CI - All Available)',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => kkiapayNoProviders),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              ButtonTheme(
                minWidth: 500.0,
                height: 80.0,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all(const Color(0xff222F5A)),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                  ),
                  child: const Text(
                    'Pay Now (WEB Version)',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  onPressed: () {
                    KkiapayFlutterSdkPlatform.instance
                        .pay(kkiapay, context, callback);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        )*/

    );
  }
}