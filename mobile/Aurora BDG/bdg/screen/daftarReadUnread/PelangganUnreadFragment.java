package com.aurora.bdg.screen.daftarReadUnread;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.SearchView;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.aurora.bdg.R;
import com.aurora.bdg.model.Pelanggan;
import com.aurora.bdg.screen.mainmenu.MainMenuActivity;
import com.aurora.bdg.util.DataBaseHelper;
import com.aurora.bdg.util.LocalStorage;
import java.util.ArrayList;

/* JADX INFO: loaded from: classes.dex */
public class PelangganUnreadFragment extends Fragment {
    private static final String ARG_BLOCK_ID = "block-id";
    DataBaseHelper dataBaseHelper;
    LocalStorage localStorage;
    private OnListFragmentUnReadInteractionListener mListener;
    RecyclerView recyclerView;
    private String ruteId;
    ArrayList<Pelanggan> listPelangganUnRead = new ArrayList<>();
    PelangganUnReadAdapter pelangganUnReadAdapter = new PelangganUnReadAdapter();

    public interface OnListFragmentUnReadInteractionListener {
        void onListFragmentUnReadInteraction(Pelanggan pelanggan);
    }

    public static PelangganUnreadFragment newInstance(String str) {
        PelangganUnreadFragment pelangganUnreadFragment = new PelangganUnreadFragment();
        Bundle bundle = new Bundle();
        bundle.putString(ARG_BLOCK_ID, str);
        pelangganUnreadFragment.setArguments(bundle);
        return pelangganUnreadFragment;
    }

    @Override // androidx.fragment.app.Fragment
    public void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        if (getArguments() != null) {
            this.ruteId = getArguments().getString(ARG_BLOCK_ID);
        }
        this.localStorage = new LocalStorage(getActivity());
        this.dataBaseHelper = DataBaseHelper.getInstance(getActivity());
    }

    @Override // androidx.fragment.app.Fragment
    public View onCreateView(LayoutInflater layoutInflater, ViewGroup viewGroup, Bundle bundle) {
        View viewInflate = layoutInflater.inflate(R.layout.fragment_pelanggan_unread_list, viewGroup, false);
        if (viewInflate instanceof RecyclerView) {
            Context context = viewInflate.getContext();
            this.recyclerView = (RecyclerView) viewInflate;
            this.recyclerView.setLayoutManager(new LinearLayoutManager(context));
        }
        return viewInflate;
    }

    @Override // androidx.fragment.app.Fragment
    public void onResume() {
        super.onResume();
        this.listPelangganUnRead = this.dataBaseHelper.getPelangganUnRead(this.localStorage.getUserName(), this.ruteId, this.localStorage.getPeriodeY(), this.localStorage.getPeriodeM());
        this.pelangganUnReadAdapter.setData(this.listPelangganUnRead, this.mListener);
        this.recyclerView.setAdapter(this.pelangganUnReadAdapter);
    }

    /* JADX WARN: Multi-variable type inference failed */
    @Override // androidx.fragment.app.Fragment
    public void onAttach(Context context) {
        super.onAttach(context);
        if (context instanceof OnListFragmentUnReadInteractionListener) {
            this.mListener = (OnListFragmentUnReadInteractionListener) context;
            return;
        }
        throw new RuntimeException(context.toString() + " must implement OnListFragmentUnReadInteractionListener");
    }

    @Override // androidx.fragment.app.Fragment
    public void onDetach() {
        super.onDetach();
        this.mListener = null;
    }

    @Override // androidx.fragment.app.Fragment
    public void onViewCreated(View view, @Nullable Bundle bundle) {
        super.onViewCreated(view, bundle);
        setHasOptionsMenu(true);
    }

    @Override // androidx.fragment.app.Fragment
    public void onCreateOptionsMenu(Menu menu, MenuInflater menuInflater) {
        menuInflater.inflate(R.menu.read_unread_menu, menu);
        MenuItem menuItemFindItem = menu.findItem(R.id.action_search);
        menuItemFindItem.setOnActionExpandListener(new MenuItem.OnActionExpandListener() { // from class: com.aurora.bdg.screen.daftarReadUnread.PelangganUnreadFragment.1
            @Override // android.view.MenuItem.OnActionExpandListener
            public boolean onMenuItemActionCollapse(MenuItem menuItem) {
                return true;
            }

            @Override // android.view.MenuItem.OnActionExpandListener
            public boolean onMenuItemActionExpand(MenuItem menuItem) {
                return true;
            }
        });
        ((SearchView) menuItemFindItem.getActionView()).setOnQueryTextListener(new SearchView.OnQueryTextListener() { // from class: com.aurora.bdg.screen.daftarReadUnread.PelangganUnreadFragment.2
            @Override // androidx.appcompat.widget.SearchView.OnQueryTextListener
            public boolean onQueryTextSubmit(String str) {
                return false;
            }

            @Override // androidx.appcompat.widget.SearchView.OnQueryTextListener
            public boolean onQueryTextChange(String str) {
                PelangganUnreadFragment.this.pelangganUnReadAdapter.update(PelangganUnreadFragment.this.filterRute(str));
                return true;
            }
        });
    }

    @Override // androidx.fragment.app.Fragment
    public boolean onOptionsItemSelected(MenuItem menuItem) {
        if (menuItem.getItemId() == R.id.action_home) {
            Intent intent = new Intent(getActivity(), (Class<?>) MainMenuActivity.class);
            intent.setFlags(67108864);
            startActivity(intent);
            getActivity().finish();
            return true;
        }
        return super.onOptionsItemSelected(menuItem);
    }

    /* JADX INFO: Access modifiers changed from: private */
    public ArrayList<Pelanggan> filterRute(String str) {
        ArrayList<Pelanggan> arrayList = new ArrayList<>();
        String lowerCase = str.toLowerCase();
        for (Pelanggan pelanggan : this.listPelangganUnRead) {
            String lowerCase2 = pelanggan.getCustCode123().toLowerCase();
            String lowerCase3 = pelanggan.getCustName().toLowerCase();
            String lowerCase4 = pelanggan.getAlamat().toLowerCase();
            if (lowerCase2.contains(lowerCase) || lowerCase3.contains(lowerCase) || lowerCase4.contains(lowerCase)) {
                arrayList.add(pelanggan);
            }
        }
        return arrayList;
    }
}
