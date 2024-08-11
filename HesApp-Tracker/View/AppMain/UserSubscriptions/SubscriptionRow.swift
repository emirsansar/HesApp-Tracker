import SwiftUI

struct SubscriptionRow: View {
    
    @Binding var selectedSubscription: UserSubscription?
    
    let subscription: UserSubscription
    let index: Int
    let onRemove: () -> Void
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(subscription.serviceName)
                    .font(.system(size: 20, weight: .medium))
                Spacer(minLength: 5)
                Text(subscription.plan.planName)
                    .font(.system(size: 16, weight: .light))
            }
            .padding(.leading, 10)
            Spacer()
            Text("\((subscription.plan.planPrice / Double(subscription.personCount)), specifier: "%.2f") TL")
                .padding(.trailing)
                .font(.system(size: 18, weight: .medium))
        }
        .padding()
        .background(index % 2 == 0 ? Color.white : Color(UIColor.systemGray5))
        .clipShape(Rectangle())
        .shadow(radius: 2)
        .swipeActions {
            Button(role: .destructive) {
                selectedSubscription = subscription
                onRemove()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }
            
            Button() {
                selectedSubscription = subscription
                onEdit()
            } label: {
                Label("Edit", systemImage: "pencil.line")
            }
            .tint(.green)
        }
    }
}


struct SubscriptionRow_Previews: PreviewProvider {
    @State static var selectedSubscription: UserSubscription? = UserSubscription(
        id: UUID(),
        serviceName: "Example Service",
        plan: Plan(planName: "Example Plan", planPrice: 100.0),
        personCount: 1
    )
    
    static var previews: some View {
        SubscriptionRow(
            selectedSubscription: $selectedSubscription,
            subscription: UserSubscription(
                id: UUID(),
                serviceName: "Example Service",
                plan: Plan(planName: "Example Plan", planPrice: 100.0),
                personCount: 1
            ),
            index: 0,
            onRemove: { print("Subscription removed") },
            onEdit: { print("Edit") }
        )
    }
}
