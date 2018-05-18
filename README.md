# UITableView-Async-Delegate-Bug
Demonstration project for a bug in UITableView (UIKit framework, iOS)

Video: https://tzahola.github.io/UITableView-Async-Delegate-Bug/bug.gif

## Problem description

In some cases, `UITableView` delivers the `tableView:didSelectRowAtIndexPath:` delegate callback asynchronously, which can result in the callback being called with an `indexPath` that was previously invalidated via `reloadData`. 

## Reproducing the issue

1. Clone this repo, open the Xcode project, run the app
2. Put a breakpoint in `tableView:didSelectRowAtIndexPath:`, at the line with `NSLog`:
```
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_searchController.searchBar.text.length != 0) {
        NSLog(@"Invariant violated!");
    }
}
```
3. Simultaneously try writing something in the search bar at the top, and tapping on a table cell. Try this again, until the debugger stops at the breakpoint. (see the attached gif above)

The app is written in a way that whenever the search field is non-empty, the table view should be empty. This is achieved by synchronously calling `reloadData` on the table view from the `UISearchController`'s `updateSearchResultsForSearchController:` callback. It should be impossible to enter `tableView:didSelectRowAtIndexPath:` when the search field is non-empty, yet it happens eventually if one tries to simultaneously type into the text field and tap on a table cell. 

When this happens, the stack trace will always be the following:

```
#0	0x00000001008dd144 in -[ViewController tableView:didSelectRowAtIndexPath:]
#1	0x000000018d4e3f10 in -[UITableView _selectRowAtIndexPath:animated:scrollPosition:notifyDelegate:] ()
#2	0x000000018d537b94 in -[UITableView _userSelectRowAtPendingSelectionIndexPath:] ()
#3	0x000000018d5c28b8 in _runAfterCACommitDeferredBlocks ()
#4	0x000000018d5b898c in _cleanUpAfterCAFlushAndRunDeferredBlocks ()
#5	0x000000018d49d550 in _afterCACommitHandler ()
#6	0x00000001835b2910 in __CFRUNLOOP_IS_CALLING_OUT_TO_AN_OBSERVER_CALLBACK_FUNCTION__ ()
#7	0x00000001835b0238 in __CFRunLoopDoObservers ()
#8	0x00000001835b0884 in __CFRunLoopRun ()
#9	0x00000001834d0da8 in CFRunLoopRunSpecific ()
#10	0x00000001854b3020 in GSEventRunModal ()
#11	0x000000018d4b178c in UIApplicationMain ()
#12	0x00000001008dd308 in main
#13	0x0000000182f61fc0 in start ()
```

which suggests that this `didSelectRowAtIndexPath:` callback was scheduled _prior_ to invalidating the table view's content with `reloadData`. For some reason, `reloadData` doesn't cancel the scheduled callback, which in this case gets delivered for an `indexPath` that's no longer valid. In a real application this `indexPath` would likely be used to look up some object from a collection, which would result in an "index out of bounds" exception (and a subsequent crash). 
