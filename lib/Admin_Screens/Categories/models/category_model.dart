class Category {
final String id;
String name;
String description;
bool isActive;


Category({
required this.id,
required this.name,
this.description = 'No description',
this.isActive = true,
});
}