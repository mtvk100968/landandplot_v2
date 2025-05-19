You already have all the Firestore‐backed methods you need—now it’s just a matter of wiring them into the UI components we built. Here’s a quick mapping of which service calls feed which widget, and how you stitch them together:

---

## 1. BuyingTab

You want to show exactly one card per property, based on buyer–status. You already have:

* `UserService.getInTalksProperties(userId)` → returns properties where the user has expressed interest
* `UserService.getBoughtProperties(userId)` → returns properties the user has completed buying

We combined and de-duped those in `_fetchAllBuyingProperties()`. In your `BuyingTab` you simply do:

```dart
// inside _loadProperties()
_allPropsFuture = _fetchAllBuyingProperties();
// …
Future<List<Property>> _fetchAllBuyingProperties() async {
  final inTalks = await UserService().getInTalksProperties(widget.userId);
  final bought  = await UserService().getBoughtProperties(widget.userId);
  // merge + de-dupe by p.id …
}
```

You then inspect each `Property.buyers` list to find the `Buyer` with your `userId` (by phone), look at its `status`, and route it into one of your five sections:

* **visitPending** → Interest
* **(date reached)** → Visiting
* **negotiating** → Negotiating
* **accepted** → Purchased
* **rejected** → Rejected

---

## 2. SellingTab

For your own posted properties you have:

* `UserService.getSellerProperties(userId)` → all properties where `property.userId == userId`

You group them by `Property.stage`:

* `findingAgents` / `findingBuyers` → “Finding Buyers”
* `saleInProgress` → “Sale In Progress”
* `sold` → “Sold”

```dart
final all = await UserService().getSellerProperties(widget.userId);
final finding = all.where((p) => p.stage.startsWith('finding')).toList();
final progress = all.where((p) => p.stage == 'saleInProgress').toList();
final sold     = all.where((p) => p.stage == 'sold').toList();
```

---

## 3. AgentProfile (if you ever surface it here)

You’ve got:

* `AgentService.getPostedProperties(agentId)`
* `AgentService.getAssignedProperties(agentId)`
* `AgentService.getFindBuyerProperties(agentId)`
* `AgentService.getSalesInProgressProperties(agentId)`

Those feed your three tabs in the agent’s view exactly the same way you’re doing for the user:

* Finding buyers
* In progress sales
* (Optionally) Sold

---

## 4. Detail‐Screen mutations

All your update paths—setting visit dates, uploading proof, negotiating, accepting buyers—ultimately call one of:

* `PropertyService.updateBuyerStatus(...)`
* `PropertyService.updateBuyer(...)`
* `PropertyService.addBuyer(...)`
* `AgentService.assignAgent(...)`

And on a successful write you trigger a UI refresh by re-calling your load method:

```dart
await PropertyService().updateBuyerStatus(...);
_loadProperties();  // triggers setState & reload FutureBuilder
```

---

### Putting it all together

1. **Imports** at top of each tab/detail:

   ```dart
   import '../../services/user_service.dart';
   import '../../services/property_service.dart';
   import '../../services/agent_service.dart';  // if needed
   ```
2. **Fetch** in `initState()` or via pull-to-refresh.
3. **Build** your lists by grouping the returned `List<Property>`.
4. **On user action** (date pick, upload, negotiate, accept), call the matching service method then re-invoke your loader.

With that wiring, your UI and your Firestore services will be fully connected. Let me know which part you’d like to implement next!
