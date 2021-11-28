#ifndef REALTLB_H
#define REALTLB_H

#include "copyright.h"
#include "ipt.h"
#include "addrspace.h"

// function declarations

//----------------------------------------------------------------------
// UpdateTLB
//      Called when exception is raised and a page isn't in the TLB.
// Figures out what to do (get from IPT, or pageoutpagein) and does it.
//----------------------------------------------------------------------

void UpdateTLB(int possible_badVAddr);

//----------------------------------------------------------------------
// InsertToTLB
//      Put a vpn/phyPage combination into the TLB.
//----------------------------------------------------------------------

void InsertToTLB(int vpn, int phyPage);

//----------------------------------------------------------------------
// PageOutPageIn
//      Calls DoPageOut and DoPageIn and handles IPT and memoryTable
// bookkeeping.
//----------------------------------------------------------------------

int PageOutPageIn(int vpn);

//----------------------------------------------------------------------
// DoPageOut
//      Actually pages out a phyPage to it's swapfile.
//----------------------------------------------------------------------

void DoPageOut(int phyPage);

//----------------------------------------------------------------------
// DoPageIn
//      Actually pages in a phyPage/vpn combo from the swapfile.
//----------------------------------------------------------------------

void DoPageIn(int vpn, int phyPage);

//----------------------------------------------------------------------
// lruAlgorithm
//      Determine where a vpn should go in phymem, and therefore what
// should be paged out.
//----------------------------------------------------------------------

int lruAlgorithm(void);

//----------------------------------------------------------------------
// GetMmap
//      Return an MmapEntry structure corresponding to the vpn.  Returns
// 0 if does not exist.
//----------------------------------------------------------------------

MmapEntry *GetMmap(int vpn);

//----------------------------------------------------------------------
// VpnToPhyPage
//      Gets a phyPage from a vpn, if exists.
//----------------------------------------------------------------------

int VpnToPhyPage(int vpn);

//----------------------------------------------------------------------
// PageOutMmapSpace
//      Pages out stuff being mmaped (or just between beginPage and
// endPage.
//----------------------------------------------------------------------

void PageOutMmapSpace(int beginPage, int endPage);

#endif // TLB_H
