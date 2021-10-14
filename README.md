# ToDo
### Important Notes

**Tools**: 

* **Authentication**: Firebase
* **Database**: Firebase Firestore
* **Libaries**: FSCalendar, Slidemenu, ProgressHub

**Flowchart**: 

* Sign In -> Today Viewcontroller (root)
* tap Todo Cell -> Edit Viewcontroller
* tap New Todo Button (plus circle)  ->  New Todo Viewcontroller
* tap Complete Todo button (circle)  ->  Delete todo from Section[0], Add todo to Section[1] (Completed section)
* tap Completed seciton header  ->  Expand or collapse Completed section
* tap Option menu (top right corner) ->  Change theme actionSheet
* Calendar Viewcontroller: tap top right corner button -> switch between Week mode and Month mode

**Logics**: 

* Todos have dueDate(deadline) = today  ->  Shown in Today Viewcontroller
* Todos fall under the same List  ->   Shown in the same List Viewcontroller
* Todos has no lists  ->  Shown in Task Viewcontroller
* Calendar Viewcontroller : Shown todos in the particular date
* Todos have repeat = (daily, weekly, monthly, yearly) :
  * repeat both dueDate and remindDate
  * if todos have no remindDate  ->  repeat only dueDate
  * if todos have no dueDate  ->  automatic add dueDate when tap Complete Button
  * if remindDate or dueDate is 30th, 31th of months and next month only have 28/29 days -> remind and dueDate of the next todo will be 28/29 then change back to 30th or 31th in the following todo
  * if user edit remind or dueDate after initiation, the next remind or dueDate of the next todo will depend on the new edited  remind or dueDate


### Sign In & Create account

* **Authentication**: Firebase
* **Password requirements**: At least 8 characters with 1 special character, 1 number, 1 uppercase character
* **Reset password**: Email link

<img src="https://i.imgur.com/1ozWQR5.png">  <img src="https://i.imgur.com/stXeyqO.png">  <img src="https://i.imgur.com/FbHpXxK.png">

### Today Viewcontroller

* **Displayed todos**: with Due Date(deadline) = today
* **Todo cell components**: Complete button (circle on the left), Todo name, List name, Due Date(deadline), remind(Optional), repeat(daily, weekly, monthly, yearly or none), Prioritize button
* **Sections**: Todos & Completed Todos (expandable/collapsable)

<img src="https://i.imgur.com/6RINn7F.png">

### New Todo Viewcontroller
* **components**:  Name textField, List button, Due DatePicker, Remind DatePicker, Repeat button, Prioritize button (star), Enter button (square with arrow)
<img src="https://i.imgur.com/RO0jNgA.png">

* **Buttons: List, DatePicker, Repeat**

<img src="https://i.imgur.com/nQm8cYI.png">  <img src="https://i.imgur.com/L15vwee.png"> <img src="https://i.imgur.com/2DJMiOb.png">


### Edit Todo Viewcontroller

* **Addition**: users can enter description for todo

<img src="https://i.imgur.com/LfxMD1F.png">

### Sidemenu Viewcontroller

* **Sections**: User name & photo, Today, Task (default List), Calendar, Lists table, New list 

<img src="https://i.imgur.com/Xx0vnls.png">

<img src="https://i.imgur.com/jXyeOAL.png">

### List Viewcontroller

* **Displayed todos**: Under the same list
* **Option menu (top right corner)**: Change theme color for particular List (sync across devices through Firebase)

<img src="https://i.imgur.com/JIWFkYG.png">

<img src="https://i.imgur.com/LShkkuy.png">

### Calendar Viewcontroller

* **Week mode**

<img src="https://i.imgur.com/H1FpbDe.png">

* **Month mode**

<img src="https://i.imgur.com/CxIrDbC.png">



